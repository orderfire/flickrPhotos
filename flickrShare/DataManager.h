//
//  OFDataManager.h
//  OrderFire
//
//  Created by orderfire on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class MediaItem;

@protocol DataManagerDelegate <NSObject>
@end

@interface DataManager : NSObject 
{}

@property (nonatomic, assign) NSObject<DataManagerDelegate> *delegate;

+ (id)sharedInstance;
- (NSString*) getDocumentsDirectory;
- (NSString*) getHDImageSubDirectory;
- (NSString*) getFullHDImageDirectory;
- (NSString*) getThumbnailImageSubDirectory;
- (NSString*) getFullThumbnailImageDirectory;

- (void) createDirectoryStructureInDocuments;
- (BOOL) createDirectoryUsingPath:(NSString*) directoryPath;

- (void) copyFileFromBundleToDocuments:(NSString*)filename Directory:(NSString*)subdirectoryString OverWrite:(BOOL) overwrite;


-(UIImage*) getImageFromDocumentsDirectory:(NSString*) filename SubDirectory:(NSString*) subdirectory;
-(UIImage*) getImageFromPath:(NSString*) filePath;

@end
