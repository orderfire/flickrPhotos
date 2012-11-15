//
//  CustomUICollectionViewCell.m
//  flickrShare
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 master. All rights reserved.
//

#import "CustomUICollectionViewCell.h"
#import "DataManager.h"
#import "UIImage+imageFile.h"

@implementation CustomUICollectionViewCell
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) setItem:(MediaItem *)item   {
    //override for setting the media item, will set the thumbnail image
    if (_item != item)  {
        _item = item;
    }
    UIImage* thumbnail = [self getThumbnail:item.fileName];
    self.imageView.image = thumbnail;
    //    self.imageView = [[UIImageView alloc] initWithImage:thumbnail];
//    self.imageView.opaque = YES;
}


-(UIImage*) getThumbnail:(NSString*) filename  {
    UIImage* thumbnail = [UIImage getImageFromDocuments:filename Directory:[[DataManager sharedInstance] getFullThumbnailImageDirectory]];
    if (!thumbnail)  {   //the original image wasn't found - display an "Not found" thumbnail
        thumbnail = [UIImage imageNamed:kNO_IMAGE_FILENAME];
    }
    return thumbnail;
}



@end
