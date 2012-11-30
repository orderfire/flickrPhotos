//
//  GridViewController.h
//  AWSiOSDemo
//
//  Created by master on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "SyncManager.h"
#import "PhotoViewerViewController.h"

@interface CollectionViewController : UICollectionViewController    <UIActionSheetDelegate,
                                                                    UIGestureRecognizerDelegate,
                                                                    PhotoViewerViewControllerDelegate,
                                                                    SyncManagerDelegate>

@property (nonatomic, retain) NSMutableArray * items;
@property (nonatomic, retain) NSMutableArray * sectionTitles;       //unused - refactor later (section groupings)
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, strong) PhotoViewerViewController* photoViewer;

- (void)     resetCollectionGridViewer;
- (BOOL)     loadImagesFromSyncManager;
- (IBAction) refreshAPI:(id)sender;

@end
