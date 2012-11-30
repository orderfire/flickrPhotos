//
//  DataManager.m
//  OrderFire
//
//  Created by orderfire on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MediaItem.h"


#pragma mark Public
@implementation DataManager

+(NSString*) getDocumentsDirectory  {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


+(NSString*) getHDImageSubDirectory  {
    NSString* subdirectory = [NSString stringWithFormat:@"%@",kIMAGE_DIRECTORY];
    return subdirectory;
}


+(NSString*) getFullHDImageDirectory  {
    NSString* directory = [[self getDocumentsDirectory] stringByAppendingFormat:@"/%@",[self getHDImageSubDirectory]];
    return directory;
}


+(NSString*) getThumbnailImageSubDirectory  {
    NSString* subdirectory = [NSString stringWithFormat:@"%@",kTHUMBNAIL_IMAGE_DIRECTORY];
    return subdirectory;
}


+(NSString*) getFullThumbnailImageDirectory  {
    NSString* directory = [[self getDocumentsDirectory] stringByAppendingFormat:@"/%@",[self getThumbnailImageSubDirectory]];
    return directory;
}


+(void) createDirectoryStructureInDocuments  {
    NSMutableArray* directories = [[NSMutableArray alloc] init];
    [directories addObject:[self getHDImageSubDirectory]];
    [directories addObject:[self getThumbnailImageSubDirectory]];

    NSLog(@"\nCreating # %i Directories",[directories count]);
    for (int i=0;i<[directories count];i++)
    {
        NSString* directoryPath = [directories objectAtIndex:i];
            if ([self createDirectoryUsingPath:[[self getDocumentsDirectory] stringByAppendingFormat:@"/%@",directoryPath]])  {
                NSLog(@"Created directory in docs: %@", directoryPath);
            }
    }
}


+(BOOL) createDirectoryUsingPath:(NSString*) directoryPath {
    NSError* error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])  {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
        {
            return NO;
           // NSLog(@"Could not create directory image.      %@,%@", error, [error userInfo]);
        }
        return YES;
    }
    return NO;
}




+(BOOL) checkFileExistsInDocumentsDirectory: (NSString *) filename Path:(NSString*) path
{ //returns TRUE if file is in docs dir, FALSE if NOT in directory
	NSString *fullFilePath			= [[self getDocumentsDirectory] stringByAppendingFormat:@"%@/%@.plist", path,filename];
	if ( [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath] )
		return TRUE;		
	else
		return FALSE;		
}


//Move Image Files
+(UIImage*) getImageFromDocumentsDirectory:(NSString*) filename SubDirectory:(NSString*) subdirectory  {
    NSString *docsFilePath;
    if (subdirectory)   {
        docsFilePath         = [[DataManager  getDocumentsDirectory] stringByAppendingFormat:@"/%@/%@",subdirectory,filename];
    }
    else    {
        docsFilePath         = [[DataManager  getDocumentsDirectory] stringByAppendingFormat:@"/%@",filename];
    }
    return [self getImageFromPath:docsFilePath];
}


+(UIImage*) getImageFromPath:(NSString*) filePath  {
    //NSLog(@"%@", filePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])  {
        return nil;
    }
    else  {
        return [UIImage imageWithContentsOfFile:filePath];
    }
}



@end
