//
//  GridViewController.m
//  AWSiOSDemo
//
//  Created by master on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"
#import "MediaItem.h"
#import "DataManager.h"
#import "CustomUICollectionViewCell.h"

#define kCollectionReuseIdentifier @"CustomCell"

@interface GridViewController ()

@end

@implementation GridViewController
@synthesize toolbar;
@synthesize actionBarButtonItem;
@synthesize toggleSelectBarButton;
@synthesize uploadBarButton;
@synthesize selectedIndexes = _selectedItems;
@synthesize items = _items;
@synthesize sectionTitles = _sectionTitles;
@synthesize longTapGesture = _longTapGesture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.items              = [[NSMutableArray alloc] init];
    self.selectedIndexes    = [[NSMutableArray alloc] init];
    self.sectionTitles      = [[NSMutableArray alloc] init];

    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Back"    style:UIBarButtonItemStylePlain target:self action:@selector(navBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"View By" style:UIBarButtonItemStylePlain target:self action:@selector(viewByPressed:)];

    self.navigationItem.title = @"My Photos";
    
    [self initializeData];
    [self checkToggleSelect];
    [[SyncManager sharedInstance] setDelegate:self];
    
    
    [self.view setBackgroundColor:[UIColor blackColor]];
  //  [self.collectionView registerNib:@"CustomCollectionCell" forCellWithReuseIdentifier:kCustomCollectionCell];
    [self.collectionView registerClass:[CustomUICollectionViewCell class] forCellWithReuseIdentifier:kCollectionReuseIdentifier];
}


- (void)viewDidUnload
{
    [self setToolbar:nil];
    [self setActionBarButtonItem:nil];
    [self setToggleSelectBarButton:nil];
    [self setUploadBarButton:nil];
    [self setItems:nil];
    [self setSelectedIndexes:nil];
    [self setSectionTitles:nil];
    [super viewDidUnload];
}


-(void) viewWillAppear:(BOOL)animated
{

    self.longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapGesture:)];
    self.longTapGesture.minimumPressDuration = 0.5;
    self.longTapGesture.delegate = self;
    [[self view] addGestureRecognizer:self.longTapGesture];
}


-(void) viewWillDisappear:(BOOL)animated
{
    [[self view] removeGestureRecognizer:self.longTapGesture];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (BOOL) initializeData
{
    [self loadImagesFromSyncManager];
    //[self.items addObject:[[SyncManager sharedInstance] updatedData]];
    [self.sectionTitles addObject:[NSString stringWithString:@"Flickr Photos"]];

/*    //create the list of photos
    [myPhotos addObject:[NSString stringWithString:@"square.png"]];
    [myPhotos addObject:[NSString stringWithString:@"square.png"]];
    [myPhotos addObject:[NSString stringWithString:@"square.png"]];
    [myPhotos addObject:[NSString stringWithString:@"square.png"]];
    [myPhotos addObject:[NSString stringWithString:@"square.png"]];
    [myPhotos addObject:[NSString stringWithString:@"square.png"]];
    [myPhotos addObject:[NSString stringWithString:@"square.png"]];
    [self.items addObject:myPhotos];
    [self.items addObject:myPhotos];
    [self.items addObject:myPhotos];

    //set titles
    [self.sectionTitles addObject:[NSString stringWithString:@"My Photos"]];
    [self.sectionTitles addObject:[NSString stringWithString:@"Shared"]];
    [self.sectionTitles addObject:[NSString stringWithString:@"Total"]];
*/
  //  NSAssert([self.sectionTitles count] == [self.items count], @"Assert. section title # doesn't match # sections in items. \n %i != %i", [self.sectionTitles count], [self.items count]);
   
 //   NSLog(@"Initialize: %@",    self.items);
 //   NSLog(@"SectionTitles: %@", self.sectionTitles);
}


-(BOOL) loadImagesFromSyncManager   {
    NSMutableArray* syncManagerItems = [NSMutableArray arrayWithArray:[[SyncManager sharedInstance] responseArray]];
    if ([syncManagerItems count] > 0)  {
        for (id syncItem in syncManagerItems) {
            if (![self.items containsObject:(MediaItem*)syncItem])   {
                //it's a new photo! Copy it into the view controller's list of photos
                [self.items addObject:syncItem];
                NSLog(@"#:    %i",[self.items count]);
            }
            else{
                NSLog(@"Item already in viewController list");
            }
        }
        return YES;
    }
    else    {
            //empty - sync probably not complete yet
        NSLog(@"Empty list");
        return NO;
    }
    
    
}


#pragma mark GESTURE METHODS
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  /*  self.initialGesturePoint = [touch locationInView:self.tableView];
    NSIndexPath * touchedIndexPath = [self.tableView indexPathForRowAtPoint:self.initialGesturePoint];
    InventoryTableViewCell* selectedCell = (InventoryTableViewCell*)[self.tableView cellForRowAtIndexPath:touchedIndexPath];
    
    if ([self checkIfSimpleTableViewCell:selectedCell])
    {   //simple table
        return NO;
    }
    else
    {  //it's an inventoryTableViewCell (custom)
        if (touch.view == selectedCell.adjustCounter)
        {
            return NO;
        }
        else {
            return YES;
        }   
    }*/
}


-(void) longTapGesture:(UILongPressGestureRecognizer *)recognizer
{   //open photo viewer
    PhotoViewerViewController* photoViewer = [[PhotoViewerViewController alloc] initWithNibName:@"PhotoViewerViewController" bundle:nil];
    photoViewer.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoViewer];
   
    //calculate touch point to figure out the index of the selected photo (pass, along with photo array)
/*    CGPoint touchPoint = [recognizer locationInView:self.myGridView];
    KKIndexPath* indexPath = [self.myGridView indexPathForItemAtPoint:touchPoint];    
    photoViewer.title       = [self.sectionTitles objectAtIndex:[indexPath section]];
    photoViewer.photoArray  = [self.items         objectAtIndex:[indexPath section]];
    photoViewer.selectedIndex = [indexPath index];
    [self presentModalViewController:navController animated:YES];*/
}   

-(void) dismissPhotoViewer:(BOOL)animated;
{
}

/*

#pragma mark KKGRIDVIEW DATASOURCE METHODS
- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section
{
    return [[self.items objectAtIndex:section] count];
}


-(NSUInteger)numberOfSectionsInGridView:(KKGridView *)gridView
{
    return [self.items count];
}


- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath
{
    CustomKKGridViewCell *cell = [CustomKKGridViewCell cellForGridView:self.myGridView];
    cell.delegate = self;
    cell.backgroundColor = [UIColor lightGrayColor];
    NSMutableArray* sectionArray = [self.items objectAtIndex:[indexPath section]];
    cell.item = [sectionArray objectAtIndex:[indexPath index]];
    [cell loadImage];
//    [cell loadUploadedImage:item.imageFilename];
    return cell;
}


#pragma mark KKGRIDVIEW DATASOURCE METHODS -- OPTIONAL
/*
- (NSString *)gridView:(KKGridView *)gridView titleForFooterInSection:(NSUInteger)section
- (CGFloat)gridView:(KKGridView *)gridView heightForHeaderInSection:(NSUInteger)section
- (CGFloat)gridView:(KKGridView *)gridView heightForFooterInSection:(NSUInteger)section
- (UIView *)gridView:(KKGridView *)gridView viewForHeaderInSection:(NSUInteger)section
- (UIView *)gridView:(KKGridView *)gridView viewForFooterInSection:(NSUInteger)section
- (UIView *)gridView:(KKGridView *)gridView viewForRow:(NSUInteger)row inSection:(NSUInteger)section; // a row is compromised of however many cells fit in a column of a given section
- (NSArray *)sectionIndexTitlesForGridView:(KKGridView *)gridView
- (NSInteger)gridView:(KKGridView *)gridView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index

- (NSString *)gridView:(KKGridView *)gridView titleForHeaderInSection:(NSUInteger)section
{
    NSAssert(section < [self.sectionTitles count], @"empty section title!");
    NSString* sectionString = [self.sectionTitles objectAtIndex:section];
    if (sectionString) 
    {
        return sectionString; 
    }
    else {
        return @"";
    }
}

- (CGFloat)gridView:(KKGridView *)gridView heightForHeaderInSection:(NSUInteger)section     {
    return 35;
}


#pragma mark KKGRIDVIEW DELEGATE METHODS -- OPTIONAL
- (KKIndexPath *)gridView:(KKGridView *)gridView willSelectItemAtIndexPath:(KKIndexPath *)indexPath   {
    return indexPath;
}


- (KKIndexPath *)gridView:(KKGridView *)gridView willDeselectItemAtIndexPath:(KKIndexPath *)indexPath   {
    return indexPath;
}
//- (void)gridView:(KKGridView *)gridView willDisplayCell:(KKGridViewCell *)cell atIndexPath:(KKIndexPath *)indexPath;


- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath
{
    if (![self.selectedIndexes containsObject:indexPath]) {
        [self.selectedIndexes addObject:indexPath];
     //   NSLog(@"Selected Item.    %@", indexPath);
    }   
    else {
        [self.selectedIndexes removeObject:indexPath];
      //  NSLog(@"     Remove Item. %@", indexPath);
    }
    [self checkToggleSelect];
}


- (void)gridView:(KKGridView *)gridView didDeselectItemAtIndexPath:(KKIndexPath *)indexPath     {
}*/


#pragma mark USER ACTIONS
-(IBAction) navBack
{
    NSLog(@"Nav back button pressed");
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)viewByPressed:(id)sender {
    NSLog(@"View By pressed");
    
}

- (IBAction)actionPressed:(id)sender {
    NSLog(@"Action pressed");
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send via Email", nil];
    actionSheet.delegate = self;
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;    
    [actionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
}

- (IBAction)uploadImages:(id)sender {
    NSLog(@"Upload pressed\n\n\n");
    
    //  [self.selectedItems addObject:[[self.items objectAtIndex:[indexPath section]] objectAtIndex:[indexPath index]]];
    NSMutableArray* items = [[NSMutableArray alloc] init];
/*    for (KKIndexPath* currentIndex in self.selectedIndexes)
    {
        NSArray* grouped = [self.items objectAtIndex:[currentIndex section]];
        MediaItem* currentItem = [grouped objectAtIndex:[currentIndex index]];
        [items addObject:currentItem];
        NSLog(@"%@", currentItem.imageFilename);
    }
    [[SyncManager sharedInstance] uploadFileArrayRequested:[NSArray arrayWithArray:items]];*/
}

- (IBAction)toggleSelect:(id)sender {
    NSLog(@"Toggle pressed");
    [self.selectedIndexes removeAllObjects];
    [self checkToggleSelect];
}

#pragma mark UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{}


-(BOOL) checkToggleSelect  {
    if ([self.selectedIndexes count] > 0)  {
        self.toggleSelectBarButton.enabled = YES;
    }
    else {
        self.toggleSelectBarButton.enabled = NO;
    }
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.items count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [self.sectionTitles count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomUICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCollectionReuseIdentifier forIndexPath:indexPath];
    MediaItem* item = [self.items objectAtIndex:indexPath.row];
    cell.item = item;
    //cell.backgroundColor = [UIColor blueColor];
    cell.imageView.backgroundColor = [UIColor brownColor];
    return cell;
}

/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}


#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* sectionTitleString = [self.sectionTitles objectAtIndex:indexPath.section];
    MediaItem* mediaItem = [self.items objectAtIndex:indexPath.row];
    CGSize itemSize = mediaItem.thumbnail.size.width > 0 ? mediaItem.thumbnail.size : CGSizeMake(100, 100);
   // CGSize itemSize = CGSizeMake(100,100);
    itemSize.height += 10;  //spacing - height
    itemSize.width  += 10;  //spacing - width
    return itemSize;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);    //outside border
}


#pragma mark SyncManagerDelegate Methods
-(void) syncManagerRequestStarted  {
    NSLog(@"Request Started");
}


-(void) syncManagerRequestComplete  {
    NSLog(@"Request Complete");
    [self loadImagesFromSyncManager];
    [self.collectionView reloadData];
}


-(void) syncManagerRequestError  {
    NSLog(@"Request Error");
  
}

-(void) downloadImageQueueComplete  {
    NSLog(@"DownloadQueue Completed");
}

-(void) thumbnailAvailableForItem:(MediaItem *)item {
    NSLog(@"Thumbnail Available:   %@", [NSDate date]);
    //REFACTOR - display thumbnail
    
}


@end
