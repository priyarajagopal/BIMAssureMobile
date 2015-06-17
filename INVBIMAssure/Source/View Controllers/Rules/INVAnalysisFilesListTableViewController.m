//
//  INVAnalysisFilesListTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVAnalysisFilesListTableViewController.h"
#import "INVGeneralAddRemoveTableViewCell.h"
//#import "INVPagingManager+PackageMasterListing.h"

static const NSInteger SECTION_ANALYSISFILES = 0;
static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;
static const NSInteger DEFAULT_FETCH_PAGE_SIZE = 20;

@interface INVAnalysisFilesListTableViewController () <INVGeneralAddRemoveTableViewCellAcionDelegate, INVPagingManagerDelegate>
@property (nonatomic, strong) INVGenericTableViewDataSource *filesDataSource;
@property (nonatomic, strong) INVProjectManager *projectManager;
@property (nonatomic, strong) INVAnalysesManager *analysesManager;
@property (nonatomic, strong) INVPackageMutableArray files;
@property (nonatomic, assign) BOOL observersAdded;
@property (nonatomic, strong) INVPagingManager *packagesPagingManager;
@property (nonatomic, assign) NSInteger pkgCount;
@end

@implementation INVAnalysisFilesListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    UINib *projectCellNib =
        [UINib nibWithNibName:@"INVGeneralAddRemoveTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:projectCellNib forCellReuseIdentifier:@"ProjectFileCell"];
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];

    if (self.showFilesForAnalysisId) {
        [self setHeaderViewWithHeading:NSLocalizedString(@"FILES_INCLUDED_IN_ANALYSIS", nil)];
    }
    else {
        [self setHeaderViewWithHeading:NSLocalizedString(@"FILES_NOT_INCLUDED_IN_ANALYSIS", nil)];
    }
    self.refreshControl = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.dataSource = self.filesDataSource;

    [self addObserversForFileMoveNotification];
    [self fetchCountOfPackagesInProject];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObserversForFileMoveNotification];
    if (self.showFilesForAnalysisId) {
        [self pushAddedPkgMastersForAnalysesToServer];
        [self pushRemovedPkgMastersForAnalysisIdToServer];
    }
    self.projectManager = nil;
    self.analysesManager = nil;
    self.tableView.dataSource = nil;
    self.filesDataSource = nil;
    self.files = nil;
}

#pragma mark - public
- (void)resetFileEntries
{
    [self updateFilesListFromServer];
    [self.filesDataSource updateWithDataArray:self.files forSection:SECTION_ANALYSISFILES];
    [self.tableView reloadData];
}

#pragma mark - server side

- (void)fetchCountOfPackagesInProject
{
    [self.globalDataManager.invServerClient
        getPkgMasterCountForProject:self.projectId
                WithCompletionBlock:^(INVGenericResponse *response, INVEmpireMobileError *error) {
                    if (error) {
                        UIAlertController *errController = [[UIAlertController alloc]
                            initWithErrorMessage:NSLocalizedString(@"ERROR_PKGMASTER_MEMBERSHIP_LOAD", nil),
                            error.code.integerValue];
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

- (void)fetchProjectFilesForAnalysisId
{
    [self showLoadProgress];

    [self.globalDataManager.invServerClient
        getPkgMembershipForAnalysis:self.analysisId
                WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

                    if (!error) {
                        [self updateFilesListFromServer];
                        [self.filesDataSource updateWithDataArray:self.files forSection:SECTION_ANALYSISFILES];
                        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    }
                    else {
                        UIAlertController *errController = [[UIAlertController alloc]
                            initWithErrorMessage:NSLocalizedString(@"ERROR_PKGMASTER_MEMBERSHIP_LOAD", nil),
                            error.code.integerValue];
                        [self presentViewController:errController animated:YES completion:nil];
                    }
                }];
}

- (void)pushAddedPkgMastersForAnalysesToServer
{
    NSSet *currentPkgMastersForAnalyses = [self.analysesManager pkgMastersForAnalysisId:self.analysisId];
    NSMutableSet *updatedPkgMasterIds = [[NSMutableSet alloc] initWithCapacity:0];
    [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVPackage *package = obj;
        [updatedPkgMasterIds addObject:package.packageId];
    }];

    [updatedPkgMasterIds minusSet:currentPkgMastersForAnalyses];

    [self.globalDataManager.invServerClient addToAnalysis:self.analysisId
                                               pkgMasters:[updatedPkgMasterIds allObjects]
                                      withCompletionBlock:^(INVEmpireMobileError *error) {
                                          if (error) {
                                              INVLogError(@"Failed to add pkg masters %@ for rule set %@ with error %@",
                                                  updatedPkgMasterIds, self.analysisId, error);
                                          }
                                          else {
                                              INVLogDebug(@"Succesfully added pkg master %@ for rule set %@",
                                                  updatedPkgMasterIds, self.analysisId);
                                          }
                                      }];
}

- (void)pushRemovedPkgMastersForAnalysisIdToServer
{
    NSMutableSet *currentPkgMastersForAnalyses = [[self.analysesManager pkgMastersForAnalysisId:self.analysisId] mutableCopy];
    NSMutableSet *updatedPkgMasterIds = [[NSMutableSet alloc] initWithCapacity:0];
    [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVPackage *package = obj;
        [updatedPkgMasterIds addObject:package.packageId];
    }];

    [currentPkgMastersForAnalyses minusSet:updatedPkgMasterIds];

    INVAnalysisPkgMembershipArray membersToBeRemoved = [self.globalDataManager.invServerClient.analysesManager
        membershipIdsForPkgVersionIds:[currentPkgMastersForAnalyses allObjects]];

    [membersToBeRemoved enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVAnalysisPkgMembership *member = obj;
        NSNumber *idToRemove = member.membershipId;
        INVLogDebug(@"Will remove member Id %@", idToRemove);
        [self.globalDataManager.invServerClient removeAnalysisMembership:idToRemove
                                                     WithCompletionBlock:INV_COMPLETION_HANDLER {
                                                         INV_ALWAYS:
                                                         INV_SUCCESS:
                                                             INVLogDebug(@"Succesfully removed pkg massters for analysisId");

                                                         INV_ERROR:
                                                             INVLogError(
                                                                 @"Failed to remove pkg masters for analysisId with error %@:",
                                                                 error);
                                                     }];

    }];
}

#pragma mark - INVPagingManagerDelegate
- (void)onFetchedDataAtOffset:(NSInteger)offset pageSize:(NSInteger)size withError:(INVEmpireMobileError *)error
{
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

    if (!error) {
        [self fetchProjectFilesForAnalysisId];
    }
    else {
        if (error.code.integerValue != INV_ERROR_CODE_NOMOREPAGES) {
            UIAlertController *errController = [[UIAlertController alloc]
                initWithErrorMessage:NSLocalizedString(@"ERROR_PKGMASTER_MEMBERSHIP_LOAD", nil), error.code.integerValue];
            [self presentViewController:errController animated:YES completion:nil];
        }
    }
}

#pragma mark - UITableView
- (void)setHeaderViewWithHeading:(NSString *)heading
{
    UIView *headerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), DEFAULT_HEADER_HEIGHT)];
    UIColor *medGreyColor = [UIColor colorWithRed:225.0 / 255 green:225.0 / 255 blue:225.0 / 255 alpha:1.0];
    [headerView setBackgroundColor:medGreyColor];

    UILabel *headingLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(headerView.frame) - 20, DEFAULT_HEADER_HEIGHT)];
    headingLabel.text = heading;
    headingLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [headerView addSubview:headingLabel];

    [self.tableView setTableHeaderView:headerView];
}

#pragma mark - INVGeneralAddRemoveTableViewCellAcionDelegate
- (void)addRemoveFileTapped:(INVGeneralAddRemoveTableViewCell *)sender
{
    if (sender.isAdded) {
    }
}

#pragma mark - accessors
- (INVPagingManager *)packagesPagingManager
{
    if (!_packagesPagingManager) {
        _packagesPagingManager =
            [[INVPagingManager alloc] initWithTotalCount:self.pkgCount pageSize:DEFAULT_FETCH_PAGE_SIZE delegate:self];
    }
    return _packagesPagingManager;
}

- (INVProjectManager *)projectManager
{
    if (!_projectManager) {
        _projectManager = self.globalDataManager.invServerClient.projectManager;
    }
    return _projectManager;
}

- (INVAnalysesManager *)analysesManager
{
    if (!_analysesManager) {
        _analysesManager = self.globalDataManager.invServerClient.analysesManager;
    }
    return _analysesManager;
}

- (INVPackageMutableArray)files
{
    if (!_files) {
        _files = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _files;
}

- (INVGenericTableViewDataSource *)filesDataSource
{
    if (!_filesDataSource) {
        _filesDataSource = [[INVGenericTableViewDataSource alloc] initWithDataArray:self.files
                                                                         forSection:SECTION_ANALYSISFILES
                                                                       forTableView:self.tableView];

        INV_CellConfigurationBlock cellConfigurationBlock =
            ^(INVGeneralAddRemoveTableViewCell *cell, INVPackage *file, NSIndexPath *indexPath) {
                cell.name.text = file.packageName;
                cell.isAdded = self.showFilesForAnalysisId;
                cell.contentId = file.packageId;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

            };
        [_filesDataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectFileCell" configureBlock:cellConfigurationBlock];
    }
    return _filesDataSource;
}

#pragma mark - Observer Handling
- (void)addObserversForFileMoveNotification
{
    if (self.observersAdded) {
        return;
    }
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserverForName:INV_NotificationAddRemoveCell
                             object:nil
                              queue:[NSOperationQueue mainQueue]
                         usingBlock:^(NSNotification *note) {
                             NSDictionary *userInfo = note.userInfo;
                             INVGeneralAddRemoveTableViewCell *tableViewCell = userInfo[@"AddRemoveCell"];

                             if (self.showFilesForAnalysisId) {
                                 if (tableViewCell.isAdded) {
                                     [self removeFromLocalFileList:tableViewCell.contentId];
                                 }
                                 else {
                                     [self addToLocalFileList:tableViewCell.contentId];
                                 }
                             }
                             else {
                                 if (tableViewCell.isAdded) {
                                     [self addToLocalFileList:tableViewCell.contentId];
                                 }
                                 else {
                                     [self removeFromLocalFileList:tableViewCell.contentId];
                                 }
                             }
                             [self.filesDataSource updateWithDataArray:self.files forSection:SECTION_ANALYSISFILES];
                             [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

                         }];
    self.observersAdded = YES;
}

- (void)removeObserversForFileMoveNotification
{
    if (!self.observersAdded) {
        return;
    }
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:INV_NotificationAddRemoveCell object:nil];
    self.observersAdded = NO;
}

#pragma mark - helpers
- (void)updateFilesListFromServer
{
    self.files = [[self.projectManager packagesForProjectId:self.projectId] mutableCopy];
    NSSet *filesMasterIdsInAnalyses = [self.analysesManager pkgMastersForAnalysisId:self.analysisId];
    INVPackageMutableArray filesAssociatedWithAnalysis =
        [[self.projectManager packageFilesForMasterIds:[filesMasterIdsInAnalyses allObjects]] mutableCopy];
    if (self.showFilesForAnalysisId) {
        self.files = filesAssociatedWithAnalysis;
    }
    else {
        if (filesAssociatedWithAnalysis && filesAssociatedWithAnalysis.count) {
            [self.files removeObjectsInArray:filesAssociatedWithAnalysis];
        }
    }
}

- (void)removeFromLocalFileList:(NSNumber *)fileMasterId
{
    @synchronized(self)
    {
        __block INVPackage *file;
        [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVPackage *temp = obj;
            if ([temp.packageId isEqualToNumber:fileMasterId]) {
                file = obj;
                *stop = YES;
            }
        }];
        if (file) {
            [self.files removeObject:file];
        }
    }
}

- (void)addToLocalFileList:(NSNumber *)fileMasterId
{
    @synchronized(self)
    {
        __block INVPackage *file;
        NSArray *packages = [self.projectManager packagesForProjectId:self.projectId];
        [packages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVPackage *temp = obj;
            if ([temp.packageId isEqualToNumber:fileMasterId]) {
                file = obj;
                *stop = YES;
            }
        }];
        if (file) {
            [self.files addObject:file];
        }
    }
}

- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.files.count - 1 == indexPath.row) {
        INVLogDebug(@"Will fetch next batch");

        [self fetchPackagesListFromCurrentOffset];
    }
}

@end
