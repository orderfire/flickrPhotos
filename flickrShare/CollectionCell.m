//
//  GridViewController.h
//  AWSiOSDemo
//
//  Created by master on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import "CollectionCell.h"

@implementation CollectionCell
@synthesize item = _item;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void) refreshThumbnail    {
    
    UIImage* thumbnail = [self.item getThumbnailImage];
    if (!thumbnail)    {
        thumbnail = [UIImage imageNamed:kNO_IMAGE_FILENAME];
    }
    self.collectionImageView.image = thumbnail;
}


@end
