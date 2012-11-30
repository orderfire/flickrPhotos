//
//  SyncManager.m
//  flickrShare
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 master. All rights reserved.
//

#define kFlickrURL @"http://api.flickr.com/services/feeds/photos_public.gne"

#import "SyncManager.h"
#import "Reachability.h"
#import "SMXMLDocument.h"
#import "MediaItem.h"
#import "ASIHTTPRequest.h"
#import "DataManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation SyncManager
@synthesize delegate = _delegate;
@synthesize downloadedItems = _downloadedItems;
@synthesize networkStatus = _networkStatus;
@synthesize feedURL = _feedURL;
@synthesize responseArray = _responseArray;
@synthesize flickrRequest = _flickrRequest;
@synthesize networkQueue = _networkQueue;

static SyncManager *sharedInstance = nil;

// Get the shared instance and create it if necessary
+ (SyncManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}


-(BOOL) checkNetworkConnection  {
    //check wifi network connection
    Reachability *connection = [Reachability reachabilityForLocalWiFi];
    if ([connection currentReachabilityStatus] != NotReachable)  {
        self.networkStatus = wifiAvailable;          //wifi on
        return YES;
    }
    else {
        //check cellular network connection
        connection = [Reachability reachabilityForInternetConnection];
        if ([connection currentReachabilityStatus] != NotReachable)  {
            self.networkStatus = cellularAvailable;      //edge, 3G, or 4G available
            return YES;
        }
        else  {
            self.networkStatus = noConnection;
            return NO;
        }
    }
}

#pragma mark FLICKR Request Methods
-(BOOL) downloadFlickrPhotos
{
    if ([self checkNetworkConnection])
    {
        self.flickrRequest = [SMWebRequest requestWithURL:[NSURL URLWithString:@"http://api.flickr.com/services/feeds/photos_public.gne"]
                                           delegate:(id<SMWebRequestDelegate>)self
                                            context:nil];
        [self.flickrRequest addTarget:self action:@selector(flickrRequestComplete:)  forRequestEvents:SMWebRequestEventComplete];
        [self.flickrRequest addTarget:self action:@selector(flickrRequestError:)     forRequestEvents:SMWebRequestEventError];
        [self.flickrRequest start];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        if ([self.delegate respondsToSelector:@selector(syncManagerRequestStarted)])
        {
            [self.delegate syncManagerRequestStarted];
        }
        return YES;
    }
    else    {
        return NO;
    }
}


- (void) flickrRequestComplete:(NSData *)data {
    //process XML
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    SMXMLDocument *document = [SMXMLDocument documentWithData:data];    //NOTE: SMXMLDocument happens on background thread
    NSArray *itemsXml = [document.root childrenNamed:@"entry"];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (SMXMLElement *itemXml in itemsXml) {
        [items addObject:[MediaItem createWithItem:itemXml]];
    }
    self.responseArray = items;
    if ([self.delegate respondsToSelector:@selector(syncManagerRequestComplete)])
    {
        [self.delegate syncManagerRequestComplete];
    }
    [self downloadImages];  
}


- (void)flickrRequestError:(NSError *)theError {
    NSLog(@"Request Error");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([self.delegate respondsToSelector:@selector(syncManagerRequestError)])
    {
        [self.delegate syncManagerRequestError];
    }
}


#pragma mark Downlload Images Request Methods
-(void) downloadImages  {
    //will use ASIHTTPRequest & a download queue to asynchronously download images from URLs

	// Stop anything already in the queue before removing it
    [self.networkQueue cancelAllOperations];
    
	// Creating a new queue each time we use it means we don't have to worry about clearing delegates or resetting progress tracking
	self.networkQueue = [ASINetworkQueue queue];
	[self.networkQueue setDelegate:self];
	[self.networkQueue setMaxConcurrentOperationCount:kConcurrentDownloadThreads];
	[self.networkQueue setRequestDidFinishSelector:   @selector(downloadImageRequestFinished:)];
	[self.networkQueue setRequestDidFailSelector:     @selector(downloadImageRequestFailed:)];
	[self.networkQueue setQueueDidFinishSelector:     @selector(downloadImageQueueFinished:)];
    [self.networkQueue setShouldCancelAllRequestsOnFailure:NO];
    [self.networkQueue setShowAccurateProgress:NO];
    //queue up requests for each image url 
    for (MediaItem* item in self.responseArray)     {
        if (item.thumbnailSaved == NO) {
            [self downloadURLInBackground:item];
        }
    }
	[self.networkQueue go];       //image downloads starts NOW
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


//use a ASINetworkQueue to download the urls (concurrent background threads with progress notifier)
-(void) downloadURLInBackground:(MediaItem*) item    {
    //  NSLog(@"Downloading from URL: %@", item.url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:item.url];
    //stores response directly in a file in temp directory (saves memory)
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),item.fileName]];
    [request addRequestHeader:@"filename" value:item.fileName];
    [self.networkQueue addOperation:request];
}


- (void)downloadImageRequestFinished:(ASIHTTPRequest *)request
{   //single image has been downloaded - NOT necessarily the entire queue
    //examine this / REFACTOR for performance later.  Slow search & generating thumbnail via background thread
    
    NSString* filename = [request.requestHeaders valueForKey:@"filename"];
	//NSLog(@"Image Download Finshed for file: %@",filename);
    if ([self moveImageFromTempToDocumentsDirectory:filename  SubDirectory:nil])    {
        //file was moved.   create a thumbnail from full-size
        
        //do on a background thread using GCD (dispatch async) for performance
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(queue, ^{
            
            MediaItem* item = [self getItemWithFilename:filename];
            item.thumbnail = [self generateThumbnailFromDocumentsImageFile:filename];

            //when finished, notify the delegate to update the UI on the MAIN THREAD
            dispatch_sync(dispatch_get_main_queue(), ^{
                    if (item.thumbnail) {   //thumbnail is converted / available. tell the delgate so the thumbnail image is displayed
                        if ([self.delegate respondsToSelector:@selector(thumbnailAvailableForItem:)])       {
                            [self.delegate thumbnailAvailableForItem:item];
                        }
                    }
                });
        });
    }
}

-(void) thumbnailGenerationComplete {

}

- (void)downloadImageRequestFailed:(ASIHTTPRequest *)request
{
	NSLog(@"Image Download Failed");
}


- (void)downloadImageQueueFinished:(ASINetworkQueue *)queue
{
	// release the network queue, we're all done
	if ([self.networkQueue requestsCount] == 0) {
        // Since this is a retained property, setting it to nil will release it
		// This is the safest way to handle releasing things - most of the time you only ever need to release in your accessors
		// And if you an Objective-C 2.0 property for the queue (as in this example) the accessor is generated automatically for you
		self.networkQueue = nil;
	}
	NSLog(@"Download Queue finished");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([self.delegate respondsToSelector:@selector(downloadImageQueueComplete)])
    {
        [self.delegate downloadImageQueueComplete];
    }
}

-(void) cancelDownloadQueue {
    //stop downloading images from urls
    [[self networkQueue] cancelAllOperations];
    self.networkQueue = nil;
    NSLog(@"Download Queue Cancelled");
}


-(void) dealloc {
    self.flickrRequest  = nil;
    self.networkQueue   = nil;
    [super dealloc];
}


-(BOOL) moveImageFromTempToDocumentsDirectory:(NSString*) filename SubDirectory:(NSString*) subdirectory  {
    NSError* error = nil;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString *docsFilePath;
    NSString *tempFilePath;
    
    if (subdirectory)  {
        docsFilePath         = [[DataManager  getDocumentsDirectory] stringByAppendingFormat:@"%@/%@/%@",subdirectory,kIMAGE_DIRECTORY,filename];
        tempFilePath         = [NSTemporaryDirectory()                               stringByAppendingFormat:@"%@/%@",subdirectory,filename];
    }
    else {
        docsFilePath         = [[DataManager  getDocumentsDirectory] stringByAppendingFormat:@"/%@/%@",kIMAGE_DIRECTORY,filename];
        tempFilePath         = [NSTemporaryDirectory()                               stringByAppendingFormat: @"%@",filename];
    }
    
    if ([fileMgr fileExistsAtPath:tempFilePath] == YES) {
        if ([fileMgr fileExistsAtPath:docsFilePath] == NO)    {
            [fileMgr copyItemAtPath:tempFilePath toPath:docsFilePath error:&error];
            [fileMgr removeItemAtPath:tempFilePath error:&error];
            if (error)  {
            //    NSLog(@"Error occured during file move: %@\n     From: %@\n     To: %@", error.description,tempFilePath, docsFilePath);
            }
            else    {
                [fileMgr removeItemAtPath:tempFilePath error:&error];
                return YES;
            }
        }
        else    {}   //file already exists (must have been downloaded previously)
    }
    [fileMgr removeItemAtPath:tempFilePath error:&error];
    return NO;
}


-(UIImage*) generateThumbnailFromDocumentsImageFile:(NSString*)filename   {
    //generate a thumbnail.  Doesn't yet handle retina. Refactor later.
    
    UIImage* thumbnail;

    NSString *fullPathToThumbImage  = [[DataManager  getDocumentsDirectory] stringByAppendingFormat:@"/%@/%@",kTHUMBNAIL_IMAGE_DIRECTORY,filename];
    UIImage *mainImage              = [DataManager  getImageFromDocumentsDirectory:filename SubDirectory:kIMAGE_DIRECTORY];
    if (!mainImage)
    {
        return nil; //image not found in specified directory. file missing
    }
    UIImageView* mainImageView      = [[UIImageView alloc] initWithImage:mainImage];
    BOOL widthGreaterThanHeight     = (mainImage.size.width > mainImage.size.height);
    float sideFull                  = (widthGreaterThanHeight) ? mainImage.size.height : mainImage.size.width;
    CGRect clippedRect              = CGRectMake(0, 0, sideFull, sideFull);
    
    //creating a square context the size of the final image which we will then
    // manipulate and transform before drawing in the original image
    UIGraphicsBeginImageContext(CGSizeMake(kTHUMBNAIL_SIZE, kTHUMBNAIL_SIZE));
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextClipToRect( currentContext, clippedRect);
    CGFloat scaleFactor = kTHUMBNAIL_SIZE/sideFull;
    
    if (widthGreaterThanHeight) {
        //a landscape image – make context shift the original image to the left when drawn into the context
        CGContextTranslateCTM(currentContext,-((mainImage.size.width - sideFull) / 2) * scaleFactor,0);
    }
    else {
        //a portfolio image – make context shift the original image upwards when drawn into the context
        CGContextTranslateCTM(currentContext,-((mainImage.size.height - sideFull) / 2) * scaleFactor,0);
    }
    
    //this will automatically scale any CGImage down/up to the required thumbnail side (kTHUMBNAIL_SIZE) when the CGImage gets drawn into the context on the next line of code
    CGContextScaleCTM(currentContext,scaleFactor,scaleFactor);
    [mainImageView.layer renderInContext:currentContext];
    thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(thumbnail);
    if ([imageData writeToFile:fullPathToThumbImage atomically:YES])
    {
        thumbnail = [UIImage imageWithContentsOfFile:fullPathToThumbImage];
        return thumbnail;
    }
    else
        return nil;
}


-(MediaItem*) getItemWithFilename:(NSString*) filename  {
    //brute force search, refactor later with a sorted responseArray (e.g. heapsort).  Assume filenames are unique - returns the 1st one
    
    for (MediaItem* item in self.responseArray)     {
        if ([item.fileName isEqualToString:filename])   {
            return item;
        }        
    }
    return nil;
}

@end
