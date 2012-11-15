//
//  CustomUICollectionViewCell.h
//  flickrShare
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 master. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItem.h"

@interface CustomUICollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) MediaItem*            item;

-(UIImage*) getThumbnail:(NSString*) filename;

@end
