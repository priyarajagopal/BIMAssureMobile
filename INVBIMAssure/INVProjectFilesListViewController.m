//
//  INVProjectFilesListViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFilesListViewController.h"
#import "INVProjectFileCollectionViewCell.h"
#import "INVProjectFileViewerController.h"
#import "INVFileManageRuleSetsContainerViewController.h"
#import "INVSearchView.h"

@import  CoreData;

const NSInteger CELL_WIDTH = 309;
const NSInteger CELL_HEIGHT = 282;
const NSInteger SEARCH_BAR_HEIGHT = 45;

@interface INVProjectFilesListViewController ()<INVProjectFileCollectionViewCellDelegate, INVSearchViewDataSource, INVSearchViewDelegate>
@property (nonatomic,strong)INVProjectManager* projectManager;
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)NSNumber* selectedModelId;
@property (nonatomic,strong)NSNumber* selectedFileId;
@property (nonatomic,strong)NSNumber* selectedFileVersionId;
@property (nonatomic,strong)INVSearchView* searchView;
@end

@implementation INVProjectFilesListViewController {
    NSMutableSet *_selectedTags;
    NSArray *_allTags;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.projectManager = self.globalDataManager.invServerClient.projectManager;
    
    self.title = NSLocalizedString(@"FILES", nil);
    
    UIColor * whiteColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
    [self.view setBackgroundColor:whiteColor];
    UINib* nib = [UINib nibWithNibName:@"INVProjectFileCollectionViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"ProjectFileCell"];
    
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout* currLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    [currLayout setItemSize:CGSizeMake(CELL_WIDTH,CELL_HEIGHT)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    [self fetchListOfProjectFiles];
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataResultsController fetchedObjects].count ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    INVProjectFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProjectFileCell" forIndexPath:indexPath];
    
    // Configure the cell
    NSManagedObject* managedFileObj = [self.dataResultsController objectAtIndexPath:indexPath];
    INVFile* file = [MTLManagedObjectAdapter modelOfClass:[INVFile class] fromManagedObject:managedFileObj error:nil];
    
    cell.modelId = [self modelIdForTipOfFile:file];
    cell.fileId  = file.fileId;
    cell.fileVersionId = file.tipId;
    cell.fileName.text = file.fileName;
    cell.delegate = self;
    
#warning - get the thumbnail image from server and update asynchronously. For now pick from bundle
    NSString* thumbNailFile = [file.fileName stringByReplacingOccurrencesOfString:@"epk" withString:@"png"];
    cell.fileThumbnail.image = [UIImage imageNamed:thumbNailFile];
#warning - eventually deal with file versions
    return cell;
}

#pragma mark <UICollectionViewDelegate>


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



#pragma mark - server side
-(void)fetchListOfProjectFiles {
    [self.globalDataManager.invServerClient getAllFilesForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {

#pragma note Yes - you could have directly accessed accounts from project manager. Using FetchResultsController directly makes it simpler
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                NSLog(@"%s. %@",__func__,self.dataResultsController.fetchedObjects);
                [self.collectionView reloadData];
            }
            else {
#warning - display error
            }
            
        }
        else {
#warning - display error
        }
    }];
}


#pragma mark - accessor
-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.projectManager.fetchRequestForProjectFiles managedObjectContext:self.projectManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    }
    return  _dataResultsController;
}

-(INVSearchView*)searchView {
    if (!_searchView) {
        _searchView = [[[NSBundle mainBundle] loadNibNamed:@"INVSearchView" owner:self options:nil] firstObject];
        _searchView.dataSource = self;
        _searchView.delegate = self;
        
        _allTags = @[
            @"Foo",
            @"Bar",
            @"Baz",
        ];
        
        _selectedTags = [NSMutableSet new];
    }
    
    return _searchView;
}
#pragma mark - INVProjectFileCollectionViewCellDelegate
-(void)onViewProjectFile:(id)sender {
    NSLog(@"%s",__func__);
    INVProjectFileCollectionViewCell* fileCell = (INVProjectFileCollectionViewCell*)sender;
    self.selectedModelId = fileCell.modelId;
    self.selectedFileVersionId = fileCell.fileVersionId;
    [self performSegueWithIdentifier:@"FileViewerSegue" sender:self];
}

-(void)onManageRuleSetsForProjectFile:(id)sender {
    NSLog(@"%s",__func__);
    INVProjectFileCollectionViewCell* fileCell = (INVProjectFileCollectionViewCell*)sender;
    self.selectedFileId = fileCell.fileId;
    [self performSegueWithIdentifier:@"RuleSetFilesSegue" sender:self];
}



 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"FileViewerSegue"]) {

        [self.tabBarController setHidesBottomBarWhenPushed:YES];
        INVProjectFileViewerController *vc = (INVProjectFileViewerController*)segue.destinationViewController;
        
        vc.modelId = self.selectedModelId;
        vc.fileVersionId = self.selectedFileVersionId;
    }
     if ([segue.identifier isEqualToString:@"RuleSetFilesSegue"]) {
         INVFileManageRuleSetsContainerViewController* vc = (INVFileManageRuleSetsContainerViewController*)segue.destinationViewController;
         vc.projectId = self.projectId;
         vc.fileId = self.selectedFileId;
     }
 }

#pragma mark - helpers
-(NSNumber*)modelIdForTipOfFile:(INVFile*)file {
    __block INVFileVersion* tip;
    [file.fileVersions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       // tip = [MTLManagedObjectAdapter modelOfClass:[INVFileVersion class] fromManagedObject:obj error:nil];
        tip = obj;
        if (tip.fileVersionId == file.tipId) {
            *stop = YES;
        }
    }];
    
    if (tip) {
        return tip.modelId;
    }
    else {
        return nil;
    }
}

#pragma mark - UIEvent Handlers
- (IBAction)onFilterTapped:(UIButton *)sender {
    if (!_searchView) {
        // TODO: Animate show/hide.
        [self.searchView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.collectionView addSubview:self.searchView];
        
        NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:self.searchView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.collectionView
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1.0
                                                                            constant:-20];
        
        NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:self.searchView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:SEARCH_BAR_HEIGHT];
        
        NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.searchView
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.collectionView
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1
                                                                              constant:0];
        
        NSLayoutConstraint *marginConstraint = [NSLayoutConstraint constraintWithItem:self.searchView
                                                                            attribute:NSLayoutAttributeTopMargin
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.collectionView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1
                                                                             constant:8];
        
        [self.collectionView addConstraints:@[widthConstraint, heightConstraint, centerXConstraint, marginConstraint]];
        
        UICollectionViewFlowLayout* currLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
        [currLayout setSectionInset:UIEdgeInsetsMake(SEARCH_BAR_HEIGHT + 10, 0, 0, 0)];
    }
    else {
        [self.searchView removeFromSuperview];
        self.searchView = nil;
        UICollectionViewFlowLayout* currLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
        [currLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

#pragma mark - INVSearchViewDataSource

-(NSUInteger) numberOfTagsInSearchView:(INVSearchView *)searchView {
    return _allTags.count;
}

-(NSString *) searchView:(INVSearchView *)searchView tagAtIndex:(NSUInteger)index {
    return _allTags[index];
}

-(BOOL) searchView:(INVSearchView *)searchView isTagSelected:(NSString *)tag {
    return [_selectedTags containsObject:tag];
}

#pragma mark - INVSearchViewDelegate

-(void) searchView:(INVSearchView *)searchView onSearchPerformed:(NSString *)searchText {
    // TODO: Perform search
}

-(void) searchView:(INVSearchView *)searchView onSearchTextChanged:(NSString *)searchText {
    // TODO: Update real-time results (or show search history).
}

-(void) searchView:(INVSearchView *)searchView onTagAdded:(NSString *)tag {
    [_selectedTags addObject:tag];
}

-(void) searchView:(INVSearchView *)searchView onTagDeleted:(NSString *)tag {
    [_selectedTags removeObject:tag];
}

-(void) searchView:(INVSearchView *)searchView onTagsSaved:(NSOrderedSet *)tags withName:(NSString *)name {
    // TODO: Save search
}

@end
