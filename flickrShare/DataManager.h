//
//  OFDataManager.h
//  OrderFire
//
//  Created by orderfire on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//created as Singleton for reuse throughout the app.  

@class MediaItem;

@interface DataManager : NSObject 
{}

+ (NSString*) getDocumentsDirectory;
+ (NSString*) getHDImageSubDirectory;
+ (NSString*) getFullHDImageDirectory;
+ (NSString*) getThumbnailImageSubDirectory;
+ (NSString*) getFullThumbnailImageDirectory;

+ (void) createDirectoryStructureInDocuments;
+ (BOOL) createDirectoryUsingPath:(NSString*) directoryPath;

+(UIImage*) getImageFromDocumentsDirectory:(NSString*) filename SubDirectory:(NSString*) subdirectory;
+(UIImage*) getImageFromPath:(NSString*) filePath;
+(BOOL)     checkFileExistsInDocumentsDirectory: (NSString *) filename Path:(NSString*) path;

@end
