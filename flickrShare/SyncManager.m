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

@implementation SyncManager
@synthesize delegate;
@synthesize downloadedItems;
@synthesize networkStatus;
@synthesize feedURL;
@synthesize responseArray;
@synthesize request;

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
        self.request = [SMWebRequest requestWithURL:[NSURL URLWithString:@"http://api.flickr.com/services/feeds/photos_public.gne"]
                                           delegate:(id<SMWebRequestDelegate>)self
                                            context:nil];
        [request addTarget:self action:@selector(requestComplete:)  forRequestEvents:SMWebRequestEventComplete];
        [request addTarget:self action:@selector(requestError:)     forRequestEvents:SMWebRequestEventError];
        [request start];
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
}


- (void)flickrRequestError:(NSError *)theError {
    NSLog(@"Request Error");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([self.delegate respondsToSelector:@selector(syncManagerRequestError)])
    {
        [self.delegate syncManagerRequestError];
    }
}




@end
