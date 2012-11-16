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
@synthesize delegate;
@synthesize transparentView;
@synthesize image;
@synthesize backgroundImage;
@synthesize prevButton;
@synthesize nextButton;
@synthesize toolbar;
@synthesize photoArray = _photoArray;
@synthesize selectedIndex;
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
    [self setTransparentView:nil];
    [self setBackgroundImage:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [self setToolbar:nil];
    [self setPhotoArray:nil];
    [self setSelectedIndex:nil];
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self setupGestureRecognizers];
    self.transparentView.alpha = 0;
    self.image.image = [self loadImage];
}


-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeGestureRecognizers];
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
    [self dismissModalViewControllerAnimated:YES];
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
        self.image.image = [self loadImage];         
    }
    else if (direction == kLOAD_RIGHT)  {
        self.image.image = [self loadImage];         
    }
    else {  //load kLOAD_MIDDLE
        self.image.image = [self loadImage];          
    }
    NSLog(@"Index:%i",self.selectedIndex);
}

-(UIImage*) loadImage {
    MediaItem* item = [self.photoArray objectAtIndex:self.selectedIndex];
    return [item getFullImage];
}


#pragma mark - Gesture Recognizer Methods
-(void) setupGestureRecognizers
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
}


-(void) removeGestureRecognizers
{
    [[self view] removeGestureRecognizer:self.oneFingerSwipeLeftGesture];
    [[self view] removeGestureRecognizer:self.oneFingerSwipeRightGesture];
    [[self view] removeGestureRecognizer:self.longTapGesture];
    [[self view] removeGestureRecognizer:self.twoFingerTapGesture];
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
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
    NSLog(@"Swipe left");
    [self gotoPrevImage:nil];
}


- (void)oneFingerSwipeRightGesture:(UISwipeGestureRecognizer *)recognizer 
{   
    NSLog(@"Swipe right");
    [self gotoNextImage:nil];
}

-(void) twoFingerTapGesture:(UILongPressGestureRecognizer *)recognizer
{  
    NSLog(@"Two finger Tap");
}

-(void) longTapGesture:(UILongPressGestureRecognizer *)recognizer
{
    NSLog(@"Long Tap");

}


@end
