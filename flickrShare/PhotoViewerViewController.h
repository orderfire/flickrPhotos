//
//  PhotoViewerViewController.h
//  
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PhotoViewerViewControllerDelegate <NSObject>
    -(void) dismissPhotoViewer:(BOOL)animated;
@end

@interface PhotoViewerViewController : UIViewController <UIGestureRecognizerDelegate>
{}

@property (nonatomic, unsafe_unretained) NSObject<PhotoViewerViewControllerDelegate> *delegate;  
@property (nonatomic, retain) IBOutlet UIView *transparentView;
@property (nonatomic, retain) IBOutlet UIImageView *fullImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIButton *prevButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain)          NSMutableArray* photoArray;
@property (nonatomic, assign)       NSUInteger selectedIndex;
@property (nonatomic, retain)          NSDate* lastTouchDate;
@property (nonatomic, retain) UISwipeGestureRecognizer* oneFingerSwipeRightGesture;
@property (nonatomic, retain) UISwipeGestureRecognizer* oneFingerSwipeLeftGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *longTapGesture;
@property (nonatomic, retain) UITapGestureRecognizer *twoFingerTapGesture;


-(IBAction) navBack;

-(IBAction) gotoPrevImage:(id)sender;
-(IBAction) gotoNextImage:(id)sender;
-(IBAction) reloadImage:(int) direction;
-(UIImage*) loadImage;

-(void) setupGestureRecognizers;
-(void) removeGestureRecognizers;
-(void) fadeTransparentView;

@end
