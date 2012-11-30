//
//  GridViewController.h
//  AWSiOSDemo
//
//  Created by master on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "MediaItem.h"

@interface CollectionCell : UICollectionViewCell
@property (nonatomic, assign)     IBOutlet UIImageView *collectionImageView;
@property (nonatomic, retain)       MediaItem*            item;

-(void) refreshThumbnail;

@end
