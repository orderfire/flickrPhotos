//
//  SyncManager.h
//  flickrShare
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMWebRequest.h"
#import "ASINetworkQueue.h"
#import "MediaItem.h"

typedef enum {
    noConnection = 0,
    cellularAvailable,
    wifiAvailable
}  NetworkConnection;

@protocol SyncManagerDelegate <NSObject>
    -(void) syncManagerRequestStarted;
    -(void) syncManagerRequestComplete;
    -(void) syncManagerRequestError;
    -(void) thumbnailAvailableForItem: (MediaItem*) item;
    -(void) downloadImageQueueComplete;
@end


@interface SyncManager : NSObject
@property (nonatomic, assign)   NSObject<SyncManagerDelegate> *delegate;
@property(nonatomic, retain)    NSMutableArray* downloadedItems;
@property(nonatomic, readwrite) NetworkConnection networkStatus;
@property (nonatomic, retain)   NSURL *feedURL;
@property (nonatomic, retain)   SMWebRequest *flickrRequest;
@property (nonatomic, retain)   NSMutableArray *responseArray;
@property (nonatomic, retain)   ASINetworkQueue *networkQueue;


+ (id)sharedInstance;
- (BOOL) checkNetworkConnection;

#pragma mark FLICKR Request Methods
- (BOOL) downloadFlickrPhotos;
- (void) flickrRequestComplete:(NSData *)data;
- (void) flickrRequestError:(NSError *)theError;

#pragma mark Download Images Methods
- (void) downloadImages;
- (void) downloadURLInBackground:(MediaItem*) item;
- (BOOL) moveImageFromTempToDocumentsDirectory:(NSString*) filename SubDirectory:(NSString*) subdirectory;
- (UIImage*) generateThumbnailFromDocumentsImageFile:(NSString*)filename;

@end
