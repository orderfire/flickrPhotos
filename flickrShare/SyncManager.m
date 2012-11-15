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


@implementation SyncManager
@synthesize delegate;
@synthesize downloadedItems;
@synthesize networkStatus;
@synthesize feedURL;
@synthesize responseArray;
@synthesize flickrRequest;
@synthesize networkQueue;

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
        networkStatus = wifiAvailable;          //wifi on
        return YES;
    }
    else {
        //check cellular network connection
        connection = [Reachability reachabilityForInternetConnection];
        if ([connection currentReachabilityStatus] != NotReachable)  {
            networkStatus = cellularAvailable;      //edge, 3G, or 4G available
            return YES;
        }
        else  {
            networkStatus = noConnection;
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
        [flickrRequest addTarget:self action:@selector(flickrRequestComplete:)  forRequestEvents:SMWebRequestEventComplete];
        [flickrRequest addTarget:self action:@selector(flickrRequestError:)     forRequestEvents:SMWebRequestEventError];
        [flickrRequest start];
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
    NSLog(@"Downloading from URL: %@", item.url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:item.url];
    //stores response directly in a file in temp directory (saves memory)
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),item.fileName]];
    [request addRequestHeader:@"filename" value:item.fileName];

    [self.networkQueue addOperation:request];
}


- (void)downloadImageRequestFinished:(ASIHTTPRequest *)request
{   //single image has been downloaded - NOT necessarily the entire queue
    NSString* filename = [request.requestHeaders valueForKey:@"filename"];
	NSLog(@"Image Download Finshed for file: %@",filename);
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
//    self.networkQueue = nil;
    NSLog(@"Download Queue Cancelled");
}


-(void) dealloc {
    self.flickrRequest  = nil;
    self.networkQueue   = nil;
}

@end
