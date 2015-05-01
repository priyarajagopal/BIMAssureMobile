//
//  INVProjectFilesListViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFilesListViewController.h"
#import "INVProjectFileCollectionViewCell.h"
#import "INVModelViewerContainerViewController.h"
#import "INVProjectFileViewerController.h"
#import "INVFileManageRuleSetsContainerViewController.h"
#import "INVRunRulesTableViewController.h"
#import "INVAnalysisExecutionsTableViewController.h"
#import "INVSearchView.h"
#import "UIImage+INVCustomizations.h"
#import "INVProjectListSplitViewController.h"
#import "UISplitViewController+ToggleSidebar.h"
#import "INVAnalysisRunsCollectionViewController.h"

#include <sys/utsname.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@import CoreData;

static const NSInteger CELL_WIDTH = 309;
static const NSInteger CELL_HEIGHT = 282;
static const NSInteger SEARCH_BAR_HEIGHT = 45;
static const NSInteger DEFAULT_FETCH_PAGE_SIZE = 20;

@interface INVProjectFilesListViewController () <INVProjectFileCollectionViewCellDelegate, INVSearchViewDataSource,
    INVSearchViewDelegate, INVPagingManagerDelegate, UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate,
    UIGestureRecognizerDelegate>

@property IBOutlet INVTransitionToStoryboard *showAnalysisRunsTransition;

@property BOOL shouldShowSidebarOnReappear;
@property (nonatomic, strong) INVProjectManager *projectManager;
@property (nonatomic, readwrite) NSFetchedResultsController *dataResultsController;
@property (nonatomic, strong) NSNumber *selectedModelId;
@property (nonatomic, strong) NSNumber *selectedFileId;
@property (nonatomic, strong) NSNumber *selectedFileTipId;
@property (nonatomic, strong) INVSearchView *searchView;
@property NSMutableSet *selectedTags;
@property NSArray *allTags;
@property NSMutableArray *searchHistory;
@property (nonatomic, strong) INVPagingManager *packagesPagingManager;
@property (nonatomic, assign) NSInteger pkgCount;
@end

@implementation INVProjectFilesListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = NSLocalizedString(@"MODELS", nil);
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

    UIColor *whiteColor = [UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:1.0];
    [self.view setBackgroundColor:whiteColor];
    UINib *nib = [UINib nibWithNibName:@"INVProjectFileCollectionViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"ProjectFileCell"];

    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *currLayout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    [currLayout setItemSize:CGSizeMake(CELL_WIDTH, CELL_HEIGHT)];

    self.pkgCount = 0;
}

- (void)dealloc
{
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    INVProjectListSplitViewController *splitVC = (INVProjectListSplitViewController *) self.splitViewController;
    // [splitVC.aggregateDelegate addDelegate:self];

    if (self.shouldShowSidebarOnReappear) {
        if (splitVC.displayMode != UISplitViewControllerDisplayModeAllVisible) {
            [splitVC toggleSidebar];
        }

        self.shouldShowSidebarOnReappear = NO;
    }

    [self fetchPackageCount];
    ;
    [self configureDisplayModeButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.navigationItem.leftBarButtonItem = nil;
    self.dataResultsController = nil;
    self.projectManager = nil;
    self.searchView = nil;
}

- (void)configureDisplayModeButton
{
    INVProjectListSplitViewController *splitVC = (INVProjectListSplitViewController *) self.splitViewController;
    self.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataResultsController fetchedObjects].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    INVProjectFileCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"ProjectFileCell" forIndexPath:indexPath];

    // Configure the cell
    INVPackage *file = [self.dataResultsController objectAtIndexPath:indexPath];

    cell.fileId = file.packageId;
    cell.tipId = file.tipId;
    cell.normalizationPercentage.text =
        [NSString stringWithFormat:NSLocalizedString(@"NORMALIZATION_PERCENTAGE", nil), file.normalizationPercentage];
    cell.fileName.text = file.packageName;
    cell.delegate = self;
    cell.fileThumbnail.image = nil;

    struct utsname platform;
    uname(&platform);

    NSString *deviceName = @(platform.machine);

    if ([deviceName hasPrefix:@"iPad2"]) {
        cell.fileThumbnail.image = [UIImage imageNamed:@"ImageNotFound"];
    }
    else {
        [cell.loaderActivity startAnimating];

        [cell.fileThumbnail
            setImageWithURLRequest:[self.globalDataManager.invServerClient requestToGetThumbnailImageForPkgVersionId:file.tipId]
            placeholderImage:[UIImage imageNamed:@"default-project-thumbnail"]
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [cell.loaderActivity stopAnimating];
            }
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [cell.loaderActivity stopAnimating];
            }];
    }

#warning - eventually deal with file versions
    return cell;
}

#pragma mark <UICollectionViewDelegate>
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataResultsController.fetchedObjects.count - 1 == indexPath.row) {
        INVLogDebug(@"Will fetch next batch");

        [self fetchPackagesListFromCurrentOffset];
    }
}

#pragma mark - server side

- (void)fetchPackageCount
{
    [self.globalDataManager.invServerClient
        getPkgMasterCountForProject:self.projectId
                WithCompletionBlock:^(INVGenericResponse *response, INVEmpireMobileError *error) {
                    if (error) {
                        UIAlertController *errController = [[UIAlertController alloc]
                            initWithErrorMessage:NSLocalizedString(@"ERROR_PROJECTS_LOAD", nil), error];
                        [self presentViewController:errController animated:YES completion:nil];
                    }
                    else {
                        self.pkgCount = ((NSNumber *) response.response).integerValue;
                        [self fetchPackagesListFromZeroOffset];
                    }
                }];
}

- (void)fetchPackagesListFromCurrentOffset
{
    INVLogDebug();
   
    SEL sel = @selector(getAllPkgMastersForProject:WithOffset:pageSize:WithCompletionBlock:);

    [self.packagesPagingManager fetchPageFromCurrentOffsetUsingSelector:sel
                                                               onTarget:self.globalDataManager.invServerClient
                                                withAdditionalArguments:@[ self.projectId ]];
}

- (void)fetchPackagesListFromZeroOffset
{
    INVLogDebug();
    [self showLoadProgress];
    

    [self.packagesPagingManager resetOffset];

    [self fetchPackagesListFromCurrentOffset];
}

#pragma mark - INVPagingManagerDelegate

- (void)onFetchedDataAtOffset:(NSInteger)offset pageSize:(NSInteger)size withError:(INVEmpireMobileError *)error
{
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

    if (!error) {
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    else {
        if (error.code.integerValue != INV_ERROR_CODE_NOMOREPAGES) {
            UIAlertController *errController = [[UIAlertController alloc]
                initWithErrorMessage:NSLocalizedString(@"ERROR_PROJECTFILES_LOAD", nil), error.code.integerValue];
            [self presentViewController:errController animated:YES completion:nil];
        }
    }
}

#pragma mark - accessor
- (NSFetchedResultsController *)dataResultsController
{
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = self.projectManager.fetchRequestForPackages;
        NSPredicate *matchPredicate = [NSPredicate predicateWithFormat:@"projectId == %@", self.projectId];
        [fetchRequest setPredicate:matchPredicate];

        _dataResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:self.projectManager.managedObjectContext
                                                  sectionNameKeyPath:nil
                                                           cacheName:nil];
        _dataResultsController.delegate = self;
        NSError *dbError;
        [_dataResultsController performFetch:&dbError];

        if (dbError) {
            _dataResultsController = nil;
        }
    }
    return _dataResultsController;
}

- (INVSearchView *)searchView
{
    if (!_searchView) {
        _searchView = [[[NSBundle mainBundle] loadNibNamed:@"INVSearchView" owner:self options:nil] firstObject];
        _searchView.dataSource = self;
        _searchView.delegate = self;

        _allTags = @[ @"John Smith", @"Jane Doe", @"David John", ];

        _selectedTags = [NSMutableSet new];
        _searchHistory = [NSMutableArray new];
    }

    return _searchView;
}

- (INVProjectManager *)projectManager
{
    if (!_projectManager) {
        _projectManager = self.globalDataManager.invServerClient.projectManager;
    }
    return _projectManager;
}

- (INVPagingManager *)packagesPagingManager
{
    if (!_packagesPagingManager) {
        _packagesPagingManager =
            [[INVPagingManager alloc] initWithTotalCount:self.pkgCount pageSize:DEFAULT_FETCH_PAGE_SIZE delegate:self];
    }
    return _packagesPagingManager;
}

#pragma mark - INVProjectFileCollectionViewCellDelegate
- (void)onViewProjectFile:(INVProjectFileCollectionViewCell *)sender
{
    INVProjectFileCollectionViewCell *fileCell = (INVProjectFileCollectionViewCell *) sender;
    self.selectedModelId = fileCell.modelId;
    self.selectedFileId = fileCell.fileId;
    self.selectedFileTipId = fileCell.tipId;
    [self performSegueWithIdentifier:@"FileViewerSegue" sender:self];
}

- (void)onManageRuleSetsForProjectFile:(INVProjectFileCollectionViewCell *)sender
{
    INVProjectFileCollectionViewCell *fileCell = (INVProjectFileCollectionViewCell *) sender;
    self.selectedModelId = fileCell.modelId;
    self.selectedFileId = fileCell.fileId;
    self.selectedFileTipId = fileCell.tipId;
    [self performSegueWithIdentifier:@"RuleSetFilesSegue" sender:self];
}

- (void)onRunRulesForProjectFile:(INVProjectFileCollectionViewCell *)sender
{
    INVProjectFileCollectionViewCell *fileCell = (INVProjectFileCollectionViewCell *) sender;
    self.selectedModelId = fileCell.modelId;
    self.selectedFileId = fileCell.fileId;
    self.selectedFileTipId = fileCell.tipId;
    [self performSegueWithIdentifier:@"RunRulesSegue" sender:self];
}

- (void)onShowExecutionsForProjectFile:(INVProjectFileCollectionViewCell *)sender
{
    INVProjectFileCollectionViewCell *fileCell = (INVProjectFileCollectionViewCell *) sender;
    self.selectedModelId = fileCell.modelId;
    self.selectedFileId = fileCell.fileId;
    self.selectedFileTipId = fileCell.tipId;

    [self.showAnalysisRunsTransition perform:self];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"FileViewerSegue"]) {
        // INVProjectFileViewerController * vc = (INVProjectFileViewerController*)segue.destinationViewController;
        //    INVModelViewerViewController *vc = (INVModelViewerViewController*)segue.destinationViewController;

        UINavigationController *navContorller = segue.destinationViewController;
        INVModelViewerContainerViewController *modelViewerController = [navContorller.viewControllers firstObject];

        modelViewerController.projectId = self.projectId;
        modelViewerController.modelId = self.selectedModelId;
        modelViewerController.packageMasterId = self.selectedFileId;
        modelViewerController.fileVersionId = self.selectedFileTipId;

        if (self.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible) {
            [self.splitViewController toggleSidebar];

            self.shouldShowSidebarOnReappear = YES;
        }
    }
    if ([segue.identifier isEqualToString:@"RuleSetFilesSegue"]) {
        INVFileManageRuleSetsContainerViewController *vc =
            (INVFileManageRuleSetsContainerViewController *) segue.destinationViewController;
        vc.projectId = self.projectId;
        vc.fileId = self.selectedFileId;
    }

    if ([segue.identifier isEqualToString:@"RunRulesSegue"]) {
        INVRunRulesTableViewController *vc = (INVRunRulesTableViewController *) segue.destinationViewController;
        vc.projectId = self.projectId;
        vc.fileVersionId = self.selectedFileTipId;
        vc.fileMasterId = self.selectedFileId;
        vc.modelId = self.selectedModelId;
    }

    if ([segue.identifier isEqualToString:@"ShowExecutionsSegue"]) {
        INVAnalysisExecutionsTableViewController *vc =
            (INVAnalysisExecutionsTableViewController *) segue.destinationViewController;
        vc.projectId = self.projectId;
        // TODO: THIS IS JUST FOR T1234ESTING. THIS WILL HAVE TO BE REPLACED WITH AN ANALYSIS RUNS VIEW THAT LISTS ALL ANALYSES
        vc.analysisRunId = @6290;
        vc.fileVersionId = self.selectedFileTipId;
        vc.fileMasterId = self.selectedFileId;
        vc.modelId = self.selectedModelId;
    }

    if ([segue.identifier isEqualToString:@"ShowAnalysisRuns"]) {
        INVAnalysisRunsCollectionViewController *vc = segue.destinationViewController;

        vc.projectId = self.projectId;
        vc.packageMasterId = self.selectedFileId;
        vc.packageVersionId = self.selectedFileTipId;

        if (self.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible) {
            [self.splitViewController toggleSidebar];

            self.shouldShowSidebarOnReappear = YES;
        }
    }
}

#pragma mark - UIEvent Handlers
- (IBAction)onFilterTapped:(UIButton *)sender
{
    if (!_searchView) {
        // TODO: Animate show/hide.
        [self.searchView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.collectionView addSubview:self.searchView];

        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.searchView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.collectionView
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1.0
                                                                            constant:-20];

        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.searchView
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

        [self.collectionView addConstraints:@[ widthConstraint, heightConstraint, centerXConstraint, marginConstraint ]];

        UICollectionViewFlowLayout *currLayout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
        [currLayout setSectionInset:UIEdgeInsetsMake(SEARCH_BAR_HEIGHT + 10, 0, 0, 0)];
    }
    else {
        [self.searchView removeFromSuperview];
        self.searchView = nil;
        UICollectionViewFlowLayout *currLayout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
        [currLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

#pragma mark - INVSearchViewDataSource

- (NSUInteger)numberOfTagsInSearchView:(INVSearchView *)searchView
{
    return _allTags.count;
}

- (NSString *)searchView:(INVSearchView *)searchView tagAtIndex:(NSUInteger)index
{
    return _allTags[index];
}

- (BOOL)searchView:(INVSearchView *)searchView isTagSelected:(NSString *)tag
{
    return [_selectedTags containsObject:tag];
}

- (NSUInteger)searchHistorySizeInSearchView:(INVSearchView *)searchView
{
    return _searchHistory.count;
}

- (NSString *)searchView:(INVSearchView *)searchView searchHistoryAtIndex:(NSUInteger)index
{
    return _searchHistory[index];
}

#pragma mark - INVSearchViewDelegate

- (void)searchView:(INVSearchView *)searchView onSearchPerformed:(NSString *)searchText
{
    // TODO: Perform search
    [_searchHistory addObject:searchText];

    // searchView.searchText = nil;
}

- (void)searchView:(INVSearchView *)searchView onSearchTextChanged:(NSString *)searchText
{
    // TODO: Update real-time results (or show search history).
}

- (void)searchView:(INVSearchView *)searchView onTagAdded:(NSString *)tag
{
    [_selectedTags addObject:tag];
}

- (void)searchView:(INVSearchView *)searchView onTagDeleted:(NSString *)tag
{
    [_selectedTags removeObject:tag];
}

- (void)searchView:(INVSearchView *)searchView onTagsSaved:(NSOrderedSet *)tags withName:(NSString *)name
{
    // TODO: Save search
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - helpers
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

@end
