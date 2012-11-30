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

#pragma mark Private
@interface DataManager ()
    -(BOOL)        checkFileExistsInDocumentsDirectory: (NSString *) filename Path:(NSString*) path;
@end


#pragma mark Public
@implementation DataManager
@synthesize delegate = _delegate;

static DataManager *sharedInstance = nil;


#pragma mark SINGLETON METHODS
+ (DataManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
     }
    return sharedInstance;
}


- (id)init {
    // We can still have a regular init method, that will get called the first time the Singleton is used
    if (self = [super init])
    {
    }
    return self;
}


// We don't want to allocate a new instance, so return the current one
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton
- (id)copyWithZone:(NSZone *)zone {
    return self;
}


-(NSString*) getDocumentsDirectory  {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


-(NSString*) getHDImageSubDirectory  {
    NSString* subdirectory = [NSString stringWithFormat:@"%@",kIMAGE_DIRECTORY];
    return subdirectory;
}


-(NSString*) getFullHDImageDirectory  {
    NSString* directory = [[self getDocumentsDirectory] stringByAppendingFormat:@"/%@",[self getHDImageSubDirectory]];
    return directory;
}


-(NSString*) getThumbnailImageSubDirectory  {
    NSString* subdirectory = [NSString stringWithFormat:@"%@",kTHUMBNAIL_IMAGE_DIRECTORY];
    return subdirectory;
}


-(NSString*) getFullThumbnailImageDirectory  {
    NSString* directory = [[self getDocumentsDirectory] stringByAppendingFormat:@"/%@",[self getThumbnailImageSubDirectory]];
    return directory;
}


-(void) createDirectoryStructureInDocuments  {
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


-(BOOL) createDirectoryUsingPath:(NSString*) directoryPath {
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


-(void) copyFileFromBundleToDocuments:(NSString*)filename Directory:(NSString*)subdirectoryString OverWrite:(BOOL) overwrite
{
    NSError* error = nil;
    //check / create subdirectories
    NSString *subdirectories = [[self getDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",subdirectoryString]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:subdirectories])  {
        [[NSFileManager defaultManager] createDirectoryAtPath:subdirectories withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
        if (error)
        {
//            NSLog(@"Could not create image subdirectories. %@", error, [error userInfo]);
        }
    }
    
    NSString *filepath = [subdirectories stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])  {
        //NSLog(@"No copy  %@  already exists",filepath);
    }
    else  {
        NSString *filenameOnly      = [filename substringToIndex:[filename length] - 4];
        NSString *filenameExtension = [filename substringFromIndex:[filename length] - 3];
        NSString* loadPath = [[NSBundle mainBundle] pathForResource:filenameOnly ofType:filenameExtension];
   //     NSLog(@"FilenameOnly: %@ ",filenameOnly);
   //     NSLog(@"FilenameExt : %@ ",filenameExtension);
   //     NSLog(@"Load From     %@",loadPath);
        
        if ([[NSFileManager defaultManager] copyItemAtPath:loadPath toPath:filepath error:&error])
        {   
        }
        if (error)
        {
        }
    }
}


- (BOOL) checkFileExistsInDocumentsDirectory: (NSString *) filename Path:(NSString*) path
{ //returns TRUE if file is in docs dir, FALSE if NOT in directory
	NSString *fullFilePath			= [[self getDocumentsDirectory] stringByAppendingFormat:@"%@/%@.plist", path,filename];
	if ( [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath] )
		return TRUE;		
	else
		return FALSE;		
}


//Move Image Files
-(UIImage*) getImageFromDocumentsDirectory:(NSString*) filename SubDirectory:(NSString*) subdirectory  {
    NSString *docsFilePath;
    if (subdirectory)   {
        docsFilePath         = [[[DataManager sharedInstance] getDocumentsDirectory] stringByAppendingFormat:@"/%@/%@",subdirectory,filename];
    }
    else    {
        docsFilePath         = [[[DataManager sharedInstance] getDocumentsDirectory] stringByAppendingFormat:@"/%@",filename];
    }
    return [self getImageFromPath:docsFilePath];
}


-(UIImage*) getImageFromPath:(NSString*) filePath  {
    //NSLog(@"%@", filePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])  {
        return nil;
    }
    else  {
        return [UIImage imageWithContentsOfFile:filePath];
    }
}



@end
