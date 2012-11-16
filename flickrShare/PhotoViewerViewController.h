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
@property (strong, nonatomic) IBOutlet UIView *transparentView;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic)          NSMutableArray* photoArray;
@property (readwrite, nonatomic)       NSUInteger selectedIndex;
@property (nonatomic, strong)          NSDate* lastTouchDate;
@property (nonatomic, strong) UISwipeGestureRecognizer* oneFingerSwipeRightGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer* oneFingerSwipeLeftGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *twoFingerTapGesture;


-(IBAction) navBack;

-(IBAction) gotoPrevImage:(id)sender;
-(IBAction) gotoNextImage:(id)sender;
-(IBAction) reloadImage:(int) direction;
-(UIImage*) loadImage;

-(void) setupGestureRecognizers;
-(void) removeGestureRecognizers;
-(void) fadeTransparentView;
-(BOOL) checkDateFromLastTouch: (NSTimeInterval) seconds;

@end
