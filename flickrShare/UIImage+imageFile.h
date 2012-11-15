//
//  UIImage+imageFile.h
//  OrderFire
//
//  Created by chef on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@interface UIImage (imageFile)
+(UIImage*) getImageFromBundle:(NSString*) fileName Subdirectory: (NSString*) subdirectory JPG:(BOOL) jpg; 
+(UIImage*) getImageFromDocuments:(NSString*) filename Directory:(NSString*) directory;

@end
