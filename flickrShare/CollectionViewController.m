//
//  GridViewController.h
//  AWSiOSDemo
//
//  Created by master on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//

#import "CollectionViewController.h"
#import "CollectionCell.h"


@implementation CollectionViewController
@synthesize items = _items;
@synthesize sectionTitles = _sectionTitles;
@synthesize backgroundImage =_backgroundImage;
@synthesize photoViewer = _photoViewer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [[SyncManager sharedInstance] setDelegate:self];
    [self resetCollectionGridViewer];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAPI:)];
    self.navigationItem.title = @"Flickr Photos";
    [self.sectionTitles addObject:@"Flickr Photos"];
    [self.collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:@"ReuseId"];
    self.collectionView.allowsSelection = YES;
    [super viewDidLoad];
}


-(BOOL) loadImagesFromSyncManager   {
    NSMutableArray* syncManagerItems = [NSMutableArray arrayWithArray:[[SyncManager sharedInstance] responseArray]];
    if ([syncManagerItems count] > 0)  {
        for (MediaItem* syncItem in syncManagerItems) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.items objectAtIndex:indexPath.row] getFullImage])    //only allow if full image is available (downloaded)
    {
        self.photoViewer = [[PhotoViewerViewController alloc] initWithNibName:@"PhotoViewerViewController" bundle:nil];
        self.photoViewer.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.photoViewer];
        self.photoViewer.photoArray  = self.items;
        self.photoViewer.selectedIndex = indexPath.row;
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self presentViewController:navController animated:YES  completion:nil];
    }
}


-(void) dismissPhotoViewer:(BOOL)animated       {   
    [self.photoViewer release];
    self.photoViewer = nil;
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}


#pragma mark - UICollectionView Datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.items count];
}




- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [self.sectionTitles count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReuseID" forIndexPath:indexPath];
    MediaItem* item = [self.items objectAtIndex:indexPath.row];
    cell.item = item;
    cell.collectionImageView.image = [UIImage imageNamed:@"no_image.jpg"];
    [cell refreshThumbnail];
    return cell;
}


#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeMake(50,50);
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
    if ([self.items containsObject:item])
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.items indexOfObject:item] inSection:0];
        NSLog(@"      Index: %@", indexPath);
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
}


-(IBAction)refreshAPI:(id)sender        {
    [[SyncManager sharedInstance] downloadFlickrPhotos];
}

-(void) resetCollectionGridViewer {
    if (self.items)
    {   
        [self.items release];
        self.items          = nil;
    }
    self.items          = [[NSMutableArray alloc] init];
    
    if (self.sectionTitles)
    {
        [self.sectionTitles release];
        self.sectionTitles  = nil;
    }
    self.sectionTitles  = [[NSMutableArray alloc] init];
    [self.collectionView reloadData];
}

@end
