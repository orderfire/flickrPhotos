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

@property (nonatomic, weak) NSObject<DataManagerDelegate> *delegate;  

+ (id)sharedInstance;
- (BOOL) saveToPlist: (NSMutableArray*) saveArray Filename: (NSString*) fileName Path: filePath Overwrite: (BOOL) overwrite;
- (NSMutableArray* )loadFromPlist: (NSString*) fileName Path: (NSString*) filePath FromBundle:(BOOL) bundle;

- (NSString*) getDocumentsDirectory;
- (NSString*) getHDImageSubDirectory;
- (NSString*) getFullHDImageDirectory;
- (NSString*) getThumbnailImageSubDirectory;
- (NSString*) getFullThumbnailImageDirectory;

- (void) createDirectoryStructureInDocuments;
- (BOOL) createDirectoryUsingPath:(NSString*) directoryPath;

- (void) copyFileFromBundleToDocuments:(NSString*)filename Directory:(NSString*)subdirectoryString OverWrite:(BOOL) overwrite;
- (BOOL) verifySampleDataStore;


-(UIImage*) getImageFromDocumentsDirectory:(NSString*) filename SubDirectory:(NSString*) subdirectory;
-(UIImage*) getImageFromPath:(NSString*) filePath;

@end
