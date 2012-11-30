//
//  MediaItem.h
//  flickrShare
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 master. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMXMLDocument.h"

@interface MediaItem : NSObject

@property(nonatomic,retain) UIImage *thumbnail;
@property(nonatomic,retain) UIImage *fullImage;
@property(nonatomic,retain) NSString *fileName;
@property(nonatomic,retain) NSString *author;
@property(nonatomic,retain) NSURL    *url;
@property(nonatomic,retain) NSString *published;
@property(nonatomic,assign) BOOL          imageDownloaded;
@property(nonatomic,assign) BOOL          thumbnailSaved;

+(MediaItem*)   createWithItem:(SMXMLElement*) element;

-(UIImage*) getThumbnailImage;
-(UIImage*) getFullImage;

@end
