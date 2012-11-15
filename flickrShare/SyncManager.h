//
//  SyncManager.h
//  flickrShare
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMWebRequest.h"

typedef enum {
    noConnection = 0,
    cellularAvailable,
    wifiAvailable
}  NetworkConnection;

@protocol SyncManagerDelegate <NSObject>
@required
    -(void) syncManagerRequestStarted;
    -(void) syncManagerRequestComplete;
    -(void) syncManagerRequestError;
    -(void) syncManagerThumbnailAvailable;
@end


@interface SyncManager : NSObject
@property (nonatomic, weak)     NSObject<SyncManagerDelegate> *delegate;
@property(nonatomic, strong)    NSMutableArray* downloadedItems;
@property(nonatomic, readwrite) NetworkConnection networkStatus;
@property (nonatomic, strong)   NSURL *feedURL;
@property (nonatomic, strong)   SMWebRequest *request;
@property (nonatomic, strong)   NSMutableArray *responseArray;


+ (id)sharedInstance;
- (BOOL) checkNetworkConnection;

#pragma mark FLICKR Request Methods
- (BOOL) downloadFlickrPhotos;
- (void) flickrRequestComplete:(NSData *)data;
- (void) flickrRequestError:(NSError *)theError;

@end
