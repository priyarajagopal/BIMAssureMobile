//
//  INVProjectFilesListViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFilesListViewController.h"
#import "INVProjectFileCollectionViewCell.h"
#import "INVModelViewerViewController.h"
#import "INVProjectFileViewerController.h"
#import "INVFileManageRuleSetsContainerViewController.h"
#import "INVRunRulesTableViewController.h"
#import "INVRuleExecutionsTableViewController.h"
#import "INVSearchView.h"
#import "UIImage+INVCustomizations.h"

@import  CoreData;

const NSInteger CELL_WIDTH = 309;
const NSInteger CELL_HEIGHT = 282;
const NSInteger SEARCH_BAR_HEIGHT = 45;

@interface INVProjectFilesListViewController ()<INVProjectFileCollectionViewCellDelegate, INVSearchViewDataSource, INVSearchViewDelegate>
@property (nonatomic,strong)INVProjectManager* projectManager;
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)NSNumber* selectedModelId;
@property (nonatomic,strong)NSNumber* selectedFileId;
@property (nonatomic,strong)NSNumber* selectedFileTipId;
@property (nonatomic,strong)INVSearchView* searchView;
@end

@implementation INVProjectFilesListViewController {
    NSMutableSet *_selectedTags;
    NSArray *_allTags;
    NSMutableArray *_searchHistory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    [self.navigationItem setLeftBarButtonItem: [self.splitViewController displayModeButtonItem]];
    [self fetchListOfProjectFiles];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.dataResultsController = nil;
    self.projectManager = nil;
    self.searchView = nil;
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
    INVPackage* file = [MTLManagedObjectAdapter modelOfClass:[INVPackage class] fromManagedObject:managedFileObj error:nil];
    
    cell.fileId  = file.packageId;
    cell.tipId = file.tipId;
    cell.fileName.text = file.packageName;
    cell.delegate = self;
    cell.fileThumbnail.image = nil;
    [cell.loaderActivity startAnimating];
        
#ifdef _USE_CANNED_THUMBNAILS_
    NSString* thumbNailFile = [file.fileName stringByReplacingOccurrencesOfString:@"epk" withString:@"png"];
    cell.fileThumbnail.image = [UIImage imageNamed:thumbNailFile];
    
#else
    
    [self.globalDataManager.invServerClient getThumbnailImageForPkgVersion:file.tipId ForSignedInAccountWithCompletionBlock:^(id data,INVEmpireMobileError *error){
        if (!error) {
            
            INVProjectFileCollectionViewCell* cell = (INVProjectFileCollectionViewCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                [cell.loaderActivity stopAnimating];
                
                // TODO: Optimize memory usage here - this resizing spikes memory usage upwards of 300MB, which isn't good.
                UIImage* origImage = [UIImage imageWithData:data];
                cell.fileThumbnail.image = [UIImage resizeImage:origImage toSize:cell.fileThumbnail.frame.size];
            }
                
        }
        else {
             UIImage* placeHolder = [UIImage imageNamed:@"ImageNotFound.jpg"];
            [cell.loaderActivity stopAnimating];
            cell.fileThumbnail.image = [UIImage resizeImage:placeHolder toSize:cell.fileThumbnail.frame.size];
            
        }
    }];
    
#endif
    
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
    [self showLoadProgress];
    [self.globalDataManager.invServerClient getAllPkgMastersForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        if (!error) {
         
#pragma note Yes - you could have directly access files from project manager. Using FetchResultsController directly makes it simpler
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                NSLog(@"%s. %@",__func__,self.dataResultsController.fetchedObjects);
                [self.collectionView reloadData];
            }
            else {
                UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_PROJECTFILES_LOAD", nil),dbError.code]];
                [self presentViewController:errController animated:YES completion:^{
                    
                }];
            }
            
        }
        else {
            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_PROJECTFILES_LOAD", nil),error.code]];
            [self presentViewController:errController animated:YES completion:^{
                
            }];

        }
    }];
}


#pragma mark - accessor
-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = self.projectManager.fetchRequestForPackages;
        NSPredicate* matchPredicate = [NSPredicate predicateWithFormat:@"projectId == %@",self.projectId];
        [fetchRequest setPredicate:matchPredicate];

         _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.projectManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    }
    return  _dataResultsController;
}

-(INVSearchView*)searchView {
    if (!_searchView) {
        _searchView = [[[NSBundle mainBundle] loadNibNamed:@"INVSearchView" owner:self options:nil] firstObject];
        _searchView.dataSource = self;
        _searchView.delegate = self;
        
        _allTags = @[
            @"John Smith",
            @"Jane Doe",
            @"David John",
        ];
        
        _selectedTags = [NSMutableSet new];
        _searchHistory = [NSMutableArray new];
    }
    
    return _searchView;
}

-(INVProjectManager*)projectManager {
    if (!_projectManager) {
        _projectManager = self.globalDataManager.invServerClient.projectManager;
        
    }
    return _projectManager;
}

#pragma mark - INVProjectFileCollectionViewCellDelegate
-(void)onViewProjectFile:(INVProjectFileCollectionViewCell*)sender {
    INVProjectFileCollectionViewCell* fileCell = (INVProjectFileCollectionViewCell*)sender;
    self.selectedModelId = fileCell.modelId;
    self.selectedFileId = fileCell.fileId;
    self.selectedFileTipId = fileCell.tipId;
    [self performSegueWithIdentifier:@"FileViewerSegue" sender:self];
}

-(void)onManageRuleSetsForProjectFile:(INVProjectFileCollectionViewCell*)sender {
    INVProjectFileCollectionViewCell* fileCell = (INVProjectFileCollectionViewCell*)sender;
    self.selectedModelId = fileCell.modelId;
    self.selectedFileId = fileCell.fileId;
    self.selectedFileTipId = fileCell.tipId;
    [self performSegueWithIdentifier:@"RuleSetFilesSegue" sender:self];
}

-(void)onRunRulesForProjectFile:(INVProjectFileCollectionViewCell*)sender {

    INVProjectFileCollectionViewCell* fileCell = (INVProjectFileCollectionViewCell*)sender;
    self.selectedModelId = fileCell.modelId;
    self.selectedFileId = fileCell.fileId;
    self.selectedFileTipId = fileCell.tipId;
    [self performSegueWithIdentifier:@"RunRulesSegue" sender:self];
}


-(void)onShowExecutionsForProjectFile:(INVProjectFileCollectionViewCell*)sender {
    
    INVProjectFileCollectionViewCell* fileCell = (INVProjectFileCollectionViewCell*)sender;
    self.selectedModelId = fileCell.modelId;
    self.selectedFileId = fileCell.fileId;
    self.selectedFileTipId = fileCell.tipId;
    [self performSegueWithIdentifier:@"ShowExecutionsSegue" sender:self];
}


 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"FileViewerSegue"]) {

         // INVProjectFileViewerController * vc = (INVProjectFileViewerController*)segue.destinationViewController;
    //    INVModelViewerViewController *vc = (INVModelViewerViewController*)segue.destinationViewController;
        
        UINavigationController *navContorller = segue.destinationViewController;
        INVModelViewerViewController *vc = [navContorller.viewControllers firstObject];
        [navContorller setHidesBottomBarWhenPushed:YES];
        
        vc.modelId = self.selectedModelId;
        vc.fileVersionId = self.selectedFileTipId;
    }
     if ([segue.identifier isEqualToString:@"RuleSetFilesSegue"]) {
         INVFileManageRuleSetsContainerViewController* vc = (INVFileManageRuleSetsContainerViewController*)segue.destinationViewController;
         vc.projectId = self.projectId;
         vc.fileId = self.selectedFileId;
     }
     
     if ([segue.identifier isEqualToString:@"RunRulesSegue"]) {
         INVRunRulesTableViewController* vc =  (INVRunRulesTableViewController*)segue.destinationViewController;
         vc.projectId = self.projectId;
         vc.fileVersionId = self.selectedFileTipId;
         vc.fileMasterId = self.selectedFileId;
         vc.modelId = self.selectedModelId;

     }
     if ([segue.identifier isEqualToString:@"ShowExecutionsSegue"]) {
         INVRuleExecutionsTableViewController* vc =  (INVRuleExecutionsTableViewController*)segue.destinationViewController;
         vc.projectId = self.projectId;
         vc.fileVersionId = self.selectedFileTipId;
         vc.fileMasterId = self.selectedFileId;
         vc.modelId = self.selectedModelId;
         
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

-(NSUInteger) searchHistorySizeInSearchView:(INVSearchView *)searchView {
    return _searchHistory.count;
}

-(NSString *) searchView:(INVSearchView *)searchView searchHistoryAtIndex:(NSUInteger)index {
    return _searchHistory[index];
}

#pragma mark - INVSearchViewDelegate

-(void) searchView:(INVSearchView *)searchView onSearchPerformed:(NSString *)searchText {
    // TODO: Perform search
    [_searchHistory addObject:searchText];
    
    // searchView.searchText = nil;
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


#pragma mark - helpers
-(void) showLoadProgress {
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

/**** DEPRECATED ******
-(NSNumber*)modelIdForTipOfFile:(INVPackage*)file {
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
 ***** DEPRECATED *******/

@end

