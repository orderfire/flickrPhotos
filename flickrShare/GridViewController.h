//
//  GridViewController.h
//  AWSiOSDemo
//
//  Created by master on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoViewerViewController.h"
#import "SyncManager.h"

@interface GridViewController : UIViewController <  UICollectionViewDataSource,
                                                    UICollectionViewDelegate,
                                                    UICollectionViewDelegateFlowLayout,
                                                    UIActionSheetDelegate,
                                                    UIGestureRecognizerDelegate,
                                                    PhotoViewerViewControllerDelegate,
                                                    SyncManagerDelegate>

{
}
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toggleSelectBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *uploadBarButton;
@property (strong, nonatomic) NSMutableArray * selectedIndexes;
@property (strong, nonatomic) NSMutableArray * items;
@property (strong, nonatomic) NSMutableArray * sectionTitles;
@property (strong, nonatomic) UILongPressGestureRecognizer* longTapGesture;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

- (BOOL)     initializeData;

- (IBAction) navBack;
- (IBAction) viewByPressed:(id)sender;
- (IBAction) actionPressed:(id)sender;
- (IBAction) uploadImages:(id)sender;
- (IBAction) toggleSelect:(id)sender;
- (BOOL)     checkToggleSelect;

-(BOOL) loadImagesFromSyncManager;

@end

