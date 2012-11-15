//
//  UIImage+imageFile.m
//  OrderFire
//
//  Created by chef on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+imageFile.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (imageFile)

+(UIImage*) getImageFromBundle:(NSString*) fileName Subdirectory: (NSString*) subdirectory JPG:(BOOL) jpg 
{
    NSString* imagePath;
    if (jpg)
        imagePath = [[NSBundle mainBundle] pathForResource:[fileName lowercaseString] ofType:@"jpg" inDirectory:nil];
    else 
        imagePath = [[NSBundle mainBundle] pathForResource:[fileName lowercaseString] ofType:@"png" inDirectory:nil];
     
    UIImage* image;
    if (imagePath)
    {
        if (jpg)
            image = [UIImage imageNamed:[[fileName lowercaseString] stringByAppendingString:@".jpg"]];
        else
            image = [UIImage imageNamed:[[fileName lowercaseString] stringByAppendingString:@".png"]];
    }
    return image;
}


+(UIImage*) getImageFromDocuments:(NSString*) filename Directory:(NSString*) directory  {

    NSString *imagePath         = [NSString stringWithFormat:@"%@/%@",directory,filename];
    NSLog(@"%@", imagePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])  {
        return nil;
    }
    else  {
        return [UIImage imageWithContentsOfFile:imagePath];
    }
}

@end
