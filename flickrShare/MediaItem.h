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

@property(nonatomic,strong) UIImage *thumbnail;
@property(nonatomic,strong) UIImage *fullImage;
@property(nonatomic,strong) NSString *fileName;
@property(nonatomic,strong) NSString *author;
@property(nonatomic,strong) NSURL    *url;
@property(nonatomic,strong) NSString *published;
@property(nonatomic,assign) BOOL          imageDownloaded;
@property(nonatomic,assign) BOOL          thumbnailSaved;

+(MediaItem*)   createWithItem:(SMXMLElement*) element;

-(UIImage*) getThumbnailImage;
-(UIImage*) getFullImage;

@end
