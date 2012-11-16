//
//  GridViewController.h
//  AWSiOSDemo
//
//  Created by master on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "MediaItem.h"

@interface CollectionCell : UICollectionViewCell
@property (weak, nonatomic)     IBOutlet UIImageView *collectionImageView;
@property (nonatomic, strong)   MediaItem*            item;

-(void) refreshThumbnail;

@end
