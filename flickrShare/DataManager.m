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
    -(BOOL)         saveArrayToPlist: (NSArray *)data FileName: (NSString *)fileName Path: (NSString*) filePath;
    -(NSArray *)	loadArrayFromFile:                  (NSString *) filePath;
    -(BOOL)        checkFileExistsInDocumentsDirectory: (NSString *) filename Path:(NSString*) path;
    -(BOOL)        saveToPlist: (NSMutableArray*) saveArray Filename: (NSString*) fileName Path: filePath;
@end


#pragma mark Public
@implementation DataManager
@synthesize delegate;

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

#pragma mark Load Data
- (BOOL)saveToPlist: (NSMutableArray*) saveArray Filename: (NSString*) fileName Path: filePath Overwrite: (BOOL) overwrite
{ 
    if (overwrite == FALSE)
    {
        if ([self checkFileExistsInDocumentsDirectory:fileName Path:filePath] == TRUE)  {  //check if file already exists
            #if kFORCE__SAVE_OVERWRITE == FALSE  
            NSLog(@"Don't save file.  Already exists.  %@",[[self getDocumentsDirectory] stringByAppendingFormat:@"/%@/%@",filePath,fileName]);
            return FALSE;
            #endif
        }
    }
    return [self saveToPlist:saveArray Filename:fileName Path:filePath];  
}


- (BOOL)saveToPlist: (NSMutableArray*) saveArray Filename: (NSString*) fileName Path: filePath
{
    if ([self saveArrayToPlist:[NSArray arrayWithArray:saveArray] FileName:fileName Path:filePath])
    {
        return TRUE; 
    }
    else
    {
        return FALSE;
    }
}


- (NSMutableArray* )loadFromPlist: (NSString*) fileName Path: (NSString*) filePath FromBundle:(BOOL) bundle
{
    NSArray* array;
    NSString *fullFilePath;
    if (bundle) {
        fullFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    }
    else    {
        fullFilePath = [[self getDocumentsDirectory] stringByAppendingFormat:@"/%@/%@.plist",filePath,fileName];
    }
    array = [self loadArrayFromFile:fullFilePath];
    return [NSMutableArray arrayWithArray:array];
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

    NSLog(@"\nCreate Directories: %i",[directories count]);
   
    for (int i=0;i<[directories count];i++)
    {
        NSString* directoryPath = [directories objectAtIndex:i];
                //[self createDirectoryUsingPath:[self getDocumentsDirecto
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
   // NSLog(@"FilePath: %@", filepath);
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
        {   //Core Data sqlite file copied to docs dir
        }
        if (error)
        {
        //    NSLog(@"Could not copy image file from bundle. %@", error, [error userInfo]);
        }
    }
}


-(BOOL) saveArrayToPlist: (NSArray *)data FileName: (NSString *)fileName Path: (NSString*) filePath  
{
	//saveDataFile used to save a data to /documents dir 
	//returns TRUE if file saved
	
	NSString *fullFilename		= [NSString stringWithFormat: @"%@.plist",fileName];
    NSString *errorString;
    
	//serialize the data (define data structure) 
    NSData *savedData = [NSPropertyListSerialization  dataFromPropertyList:data
																	format:NSPropertyListXMLFormat_v1_0
														  errorDescription:&errorString];

    if (errorString)
    {
        #if DEBUG
        NSLog(@"Error during save. Serialization error: %@",errorString);
        #endif
        return FALSE;
    }
    else 
    {
        ///check if directory exists, if it doesn't, create it
        NSString* directoryFilePath= [[self getDocumentsDirectory] stringByAppendingString:filePath];
        NSError* error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryFilePath])
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryFilePath withIntermediateDirectories:NO attributes:nil error:&error]; 

        if (error)
        {
            
            #if DEBUG
            NSLog(@"Error during save.  Directory Error: %i - %@", [error code], [error localizedDescription]);  
            #endif
            return FALSE;
        }
        else 
        {
            NSString* fullFilePath=  [[self getDocumentsDirectory] stringByAppendingFormat:@"%@/%@",fullFilename,filePath];
            if ([savedData writeToFile:fullFilePath atomically:YES] == TRUE)
                {
                #if DEBUG
                NSLog(@"File saved succcessfully");
                #endif
                    return TRUE;			//returns true if file saved successfully
            }
            else {
                #if DEBUG
                NSLog(@"Error during save.  File not saved");  
                #endif
                return FALSE;
            }
        }
    }
}


- (NSArray *)loadArrayFromFile: (NSString *)filePath 
{
    //initialize & loads data, if 1st load (file not in documents dir, then gets from bundle
    //returns	nil if load failed
    //          mutableArray if load successful
	
    NSString *error = nil;
    NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;	//need or otherwise assumes it's a binary 
    
    // convert the static property list into the corresponding property-list objects using NSPropertyListSerialization
    //NOTE!!! NEEDS TO BE AN NSARRAY or WON'T work, also need to cast the serialization
    NSArray	*data = (NSArray *)[NSPropertyListSerialization	 propertyListFromData:	[[NSFileManager defaultManager] contentsAtPath:filePath]	
                                                                 mutabilityOption:	NSPropertyListMutableContainersAndLeaves 		
                                                                           format:	&format
                                                                 errorDescription:	&error];
	
    if (!data) 
    {
        NSLog(@"Error reading plist: %@, \nformat: %d", error, format);
       // [error release];	//need this! don't remove! exception to normal retain rule
        //see http://developer.apple.com/iphone/library/documentation/Cocoa/Conceptual/PropertyLists/SerializePlist/SerializePlist.html#//apple_ref/doc/uid/10000048i-CH7-SW1
        return nil;		//failed
    }
    else
    {		
        return data;	
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
