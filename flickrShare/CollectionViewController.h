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

@property (strong, nonatomic) NSMutableArray * items;
@property (strong, nonatomic) NSMutableArray * sectionTitles;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

- (void)     resetCollectionGridViewer;
- (BOOL)     loadImagesFromSyncManager;
- (IBAction) refreshAPI:(id)sender;

@end
