//
//  PhotoViewerViewController.h
//
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kLOAD_LEFT   0
#define kLOAD_MIDDLE 1
#define kLOAD_RIGHT  2
#define kTRANSPARENT_VIEW_ALPHA 0.8
#define kTRANSPARENT_VIEW_FADEIN_DELAY  0.2
#define kTRANSPARENT_VIEW_DELAY 3
#define kTRANSPARENT_VIEW_FADEOUT_DELAY 1
#define kANIMATE_IMAGE_SWITCH_DURATION 0.5

#import "PhotoViewerViewController.h"
#import "MediaItem.h"
#import "DataManager.h"
#import <Foundation/Foundation.h>

@interface PhotoViewerViewController ()
    -(void) oneFingerSwipeLeftGesture:(UISwipeGestureRecognizer *)recognizer;
    -(void) oneFingerSwipeRightGesture:(UISwipeGestureRecognizer *)recognizer; 
    -(void) twoFingerTapGesture:(UILongPressGestureRecognizer *)recognizer;
    -(void) longTapGesture:(UILongPressGestureRecognizer *)recognizer;
@end

@implementation PhotoViewerViewController
@synthesize delegate = _delegate;
@synthesize transparentView = _transparentView;
@synthesize fullImageView = _fullImageView;
@synthesize backgroundImage = _backgroundImage;
@synthesize prevButton = _prevButton;
@synthesize nextButton = _nextButton;
@synthesize toolbar = _toolbar;
@synthesize photoArray = _photoArray;
@synthesize selectedIndex = _selectedIndex;
@synthesize oneFingerSwipeLeftGesture = _oneFingerSwipeLeftGesture;
@synthesize oneFingerSwipeRightGesture = _oneFingerSwipeRightGesture;
@synthesize longTapGesture = _longTapGesture;
@synthesize twoFingerTapGesture = _twoFingerTapGesture;
@synthesize lastTouchDate = _nextTouchDate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.photoArray = [[NSMutableArray alloc] init];
        self.selectedIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(navBack)];
}

- (void)viewDidUnload
{
    [self.photoArray release];
    self.photoArray = nil;
    [self setTransparentView:nil];
    [self setBackgroundImage:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.oneFingerSwipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeRightGesture:)];
    [self.oneFingerSwipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    self.oneFingerSwipeRightGesture.delegate = self;
    [[self view] addGestureRecognizer:self.oneFingerSwipeRightGesture];
    
    self.oneFingerSwipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeLeftGesture:)];
    [self.oneFingerSwipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    self.oneFingerSwipeLeftGesture.delegate = self;
    [[self view] addGestureRecognizer:self.oneFingerSwipeLeftGesture];
    
    self.longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapGesture:)];
    self.longTapGesture.minimumPressDuration = 0.5;
    self.longTapGesture.delegate = self;
    [[self view] addGestureRecognizer:self.longTapGesture];
    
    self.twoFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerTapGesture:)];
    self.twoFingerTapGesture.numberOfTapsRequired    = 1;
    self.twoFingerTapGesture.numberOfTouchesRequired = 2;
    self.twoFingerTapGesture.delegate = self;
    [[self view] addGestureRecognizer:self.twoFingerTapGesture];

    self.transparentView.alpha = 0;
    self.fullImageView.image = [self loadImage];
}


-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self view] removeGestureRecognizer:self.oneFingerSwipeRightGesture];
    [self.oneFingerSwipeRightGesture release];
    self.oneFingerSwipeRightGesture = nil;
    
    [[self view] removeGestureRecognizer:self.oneFingerSwipeLeftGesture];
    [self.oneFingerSwipeLeftGesture release];
    self.oneFingerSwipeLeftGesture = nil;
    
    [[self view] removeGestureRecognizer:self.longTapGesture];
    [self.longTapGesture release];
    self.longTapGesture = nil;
    
    [[self view] removeGestureRecognizer:self.twoFingerTapGesture];
    [self.twoFingerTapGesture release];
    self.twoFingerTapGesture = nil;

    if([self.delegate respondsToSelector:@selector(dismissPhotoViewer:)])
    {
        [self.delegate dismissPhotoViewer:animated];
    }   
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark USER ACTIONS
-(IBAction) navBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)gotoPrevImage:(id)sender {
    if (self.selectedIndex > 0)
    {
        self.selectedIndex--;
        [self reloadImage:kLOAD_LEFT];

    }
}

- (IBAction)gotoNextImage:(id)sender {
    if (self.selectedIndex < [self.photoArray count]-1)
    {
        self.selectedIndex++;
        [self reloadImage:kLOAD_RIGHT];
    }
}


-(IBAction) reloadImage:(int) direction
{
    if (direction == kLOAD_LEFT)  {
        [UIView animateWithDuration:kANIMATE_IMAGE_SWITCH_DURATION
                              delay:0
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^(void) {
                                    self.fullImageView.image = [self loadImage];
                                    }
                         completion:^(BOOL finished) {
                         }];
    }
    else if (direction == kLOAD_RIGHT)  {
        [UIView animateWithDuration:kANIMATE_IMAGE_SWITCH_DURATION
                              delay:0
                            options:UIViewAnimationOptionTransitionFlipFromRight
                         animations:^(void) {
                             self.fullImageView.image = [self loadImage];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    else {  //load kLOAD_MIDDLE
        [UIView animateWithDuration:kANIMATE_IMAGE_SWITCH_DURATION
                              delay:0
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^(void) {
                             self.fullImageView.image = [self loadImage];
                         }
                         completion:^(BOOL finished) {
                         }];    }
    
    NSLog(@"Index:%i",self.selectedIndex);
}

-(UIImage*) loadImage {
    MediaItem* item = [self.photoArray objectAtIndex:self.selectedIndex];
    UIImage* newImage = [item getFullImage];
    
    if ((newImage.size.height > self.fullImageView.frame.size.height) || (newImage.size.width > self.fullImageView.frame.size.width))   {
    //if the newImage is bigger than the window, have the imageView resize the image to fit
        self.fullImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else    {
        self.fullImageView.contentMode = UIViewContentModeCenter;
    }
    return newImage;
}


#pragma mark - Gesture Recognizer Methods
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //after a few seconds, fade out the overlay controls
    self.lastTouchDate = [NSDate date];
    if (self.transparentView.alpha == 0)     {
        [UIView transitionWithView:self.view
                          duration:kTRANSPARENT_VIEW_FADEIN_DELAY
                           options:UIViewAnimationCurveEaseIn
                        animations:^{
                            self.transparentView.alpha = kTRANSPARENT_VIEW_ALPHA;
                        }
                        completion:^(BOOL completion)  {
                            [self performSelector:@selector(fadeTransparentView)
                                       withObject:nil
                                       afterDelay:kTRANSPARENT_VIEW_DELAY];
                        }];
        
    }
    else    {
        [self performSelector:@selector(fadeTransparentView)
                   withObject:nil
                   afterDelay:kTRANSPARENT_VIEW_DELAY];
    }
    return TRUE;
}


-(void) fadeTransparentView {
    NSDate* checkDate = [self.lastTouchDate dateByAddingTimeInterval:kTRANSPARENT_VIEW_DELAY];
    if ([checkDate compare:[NSDate date]] == NSOrderedAscending)    {
        //fades out the overlay controls
        [UIView transitionWithView:self.view
                          duration:kTRANSPARENT_VIEW_FADEOUT_DELAY
                           options:UIViewAnimationCurveEaseIn
                        animations:^{
                            self.transparentView.alpha = 0;
                        }
                        completion:^(BOOL completion)  {
                        }];
    }
}


- (void)oneFingerSwipeLeftGesture:(UISwipeGestureRecognizer *)recognizer 
{    
    [self gotoPrevImage:nil];
}


- (void)oneFingerSwipeRightGesture:(UISwipeGestureRecognizer *)recognizer 
{   
    [self gotoNextImage:nil];
}

-(void) twoFingerTapGesture:(UILongPressGestureRecognizer *)recognizer
{  
}

-(void) longTapGesture:(UILongPressGestureRecognizer *)recognizer
{
}


@end
