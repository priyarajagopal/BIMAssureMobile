//
//  INVFileAnalysesMembershipTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVFileAnalysesMembershipTableViewController.h"
#import "INVGeneralAddRemoveTableViewCell.h"

static const NSInteger SECTION_ANALYSESLIST = 0;
static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;

@interface INVFileAnalysesMembershipTableViewController () <INVGeneralAddRemoveTableViewCellAcionDelegate>
@property (nonatomic, strong) INVGenericTableViewDataSource *analysesDataSource;
@property (nonatomic, strong) INVProjectManager *projectManager;
@property (nonatomic, strong) INVAnalysesManager *analysisManager;
@property (nonatomic, strong) INVAnalysisMutableArray analyses;
@property (nonatomic, assign) BOOL observersAdded;
@end

@implementation INVFileAnalysesMembershipTableViewController

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

    if (self.showAnalysesForPkg) {
        [self setHeaderViewWithHeading:NSLocalizedString(@"ANALYSES_INCLUDED_IN_FILE", nil)];
    }
    else {
        [self setHeaderViewWithHeading:NSLocalizedString(@"ANALYSES_NOT_INCLUDED_IN_FILE", nil)];
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
    self.tableView.dataSource = self.analysesDataSource;

    [self addObserversForFileMoveNotification];
    [self fetchListOfProjectAnalyses];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.showAnalysesForPkg) {
        [self pushAddedAnalysesForPkgMasterToServer];
        [self pushRemovedAnalysesForPkgMasterToServer];
    }
    self.tableView.dataSource = nil;
    self.analysesDataSource = nil;
    self.analysisManager = nil;
    self.projectManager = nil;
    self.analyses = nil;
    [self removeObserversForFileMoveNotification];
}

#pragma mark - public
- (void)resetAnalysesEntries
{
    [self updateAnalysesFromServer];
    [self.analysesDataSource updateWithDataArray:self.analyses forSection:SECTION_ANALYSESLIST];
    [self.tableView reloadData];
}

#pragma mark - server side
- (void)fetchListOfProjectAnalyses
{
    [self showLoadProgress];

    [self.globalDataManager.invServerClient
        getAllAnalysesForProject:self.projectId
             withCompletionBlock:INV_COMPLETION_HANDLER {
                 INV_ALWAYS:
                     [self.hud hide:YES];

                 INV_SUCCESS:
                     [self fetchAnalysesForFile];

                 INV_ERROR:
                     INVLogError(@"%@", error);

                     UIAlertController *errController = [[UIAlertController alloc]
                         initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSES_MEMBERSHIP_LOAD", nil),
                         error.code.integerValue];
                     [self presentViewController:errController animated:YES completion:nil];
             }];
}

- (void)fetchAnalysesForFile
{
    [self showLoadProgress];

    [self.globalDataManager.invServerClient
        getAnalysisMembershipForPkgMaster:self.fileId
                      WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                          [self.hud hide:YES];
                          if (!error) {
                              [self updateAnalysesFromServer];

                              [self.analysesDataSource updateWithDataArray:self.analyses forSection:SECTION_ANALYSESLIST];
                              [self.tableView reloadData];
                          }
                          else {
                              INVLogError(@"%@", error);

                              UIAlertController *errController = [[UIAlertController alloc]
                                  initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSES_MEMBERSHIP_LOAD", nil),
                                  error.code.integerValue];
                              [self presentViewController:errController animated:YES completion:nil];
                          }

                      }];
}

- (void)pushAddedAnalysesForPkgMasterToServer
{
    NSSet *currentAnalysesForPkgMaster =
        [self.globalDataManager.invServerClient.analysesManager analysesIdsForPkgMaster:self.fileId];
    NSMutableSet *updatedAnalysesIds = [[NSMutableSet alloc] initWithCapacity:0];
    [self.analyses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVAnalysis *analysis = obj;
        [updatedAnalysesIds addObject:analysis.analysisId];
    }];

    [updatedAnalysesIds minusSet:currentAnalysesForPkgMaster];

    [self.globalDataManager.invServerClient addToPkgMaster:self.fileId
                                                  analyses:[updatedAnalysesIds allObjects]
                                       withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                           INVLogDebug(@"Status is %@", error);
                                       }];
}

- (void)pushRemovedAnalysesForPkgMasterToServer
{
    NSMutableSet *currentAnalysesForPkgMaster =
        [[self.globalDataManager.invServerClient.analysesManager analysesIdsForPkgMaster:self.fileId] mutableCopy];
    NSMutableSet *updatedAnalysisIds = [[NSMutableSet alloc] initWithCapacity:0];
    [self.analyses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVAnalysis *analysis = obj;
        [updatedAnalysisIds addObject:analysis.analysisId];
    }];

    [currentAnalysesForPkgMaster minusSet:updatedAnalysisIds];

    INVAnalysisPkgMembershipArray membersToBeRemoved = [self.globalDataManager.invServerClient.analysesManager
        membershipIdsForAnalysisIds:[currentAnalysesForPkgMaster allObjects]];

    [membersToBeRemoved enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVAnalysisPkgMembership *member = obj;
        NSNumber *idToRemove = member.membershipId;
        INVLogDebug(@"Will remove member Id %@", idToRemove);
        [self.globalDataManager.invServerClient
            removeAnalysisMembership:idToRemove
                 WithCompletionBlock:INV_COMPLETION_HANDLER {
                     INV_ALWAYS:
                     INV_SUCCESS:
                         INVLogDebug(@"Succesfully removed rule set %@ for pkg master %@ ", idToRemove, self.fileId);

                     INV_ERROR:
                         INVLogError(
                             @"Failed to remove rule set %@ for pkg master %@ with error %@", idToRemove, self.fileId, error);
                 }];

    }];
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
- (INVProjectManager *)projectManager
{
    if (!_projectManager) {
        _projectManager = self.globalDataManager.invServerClient.projectManager;
    }
    return _projectManager;
}

- (INVAnalysesManager *)analysisManager
{
    if (!_analysisManager) {
        _analysisManager = self.globalDataManager.invServerClient.analysesManager;
    }
    return _analysisManager;
}

- (INVAnalysisMutableArray)analyses
{
    if (!_analyses) {
        _analyses = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _analyses;
}

- (INVGenericTableViewDataSource *)analysesDataSource
{
    if (!_analysesDataSource) {
        _analysesDataSource = [[INVGenericTableViewDataSource alloc] initWithDataArray:self.analyses
                                                                            forSection:SECTION_ANALYSESLIST
                                                                          forTableView:self.tableView];

        INV_CellConfigurationBlock cellConfigurationBlock =
            ^(INVGeneralAddRemoveTableViewCell *cell, INVAnalysis *analysis, NSIndexPath *indexPath) {
                cell.name.text = analysis.name;
                cell.isAdded = self.showAnalysesForPkg;
                cell.contentId = analysis.analysisId;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

            };
        [_analysesDataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectFileCell"
                                                         configureBlock:cellConfigurationBlock];
    }
    return _analysesDataSource;
}

#pragma mark - helpers
- (void)updateAnalysesFromServer
{
    self.analyses = [[self.analysisManager analysesForProject:self.projectId] mutableCopy];
    NSSet *analysesAssociatedWithFile = [self.analysisManager analysesIdsForPkgMaster:self.fileId];
    INVAnalysisMutableArray analysesObjectsAssociatedWithFile =
        [[self.analysisManager analysesForIds:[analysesAssociatedWithFile allObjects]] mutableCopy];
    if (self.showAnalysesForPkg) {
        self.analyses = analysesObjectsAssociatedWithFile;
    }
    else {
        if (analysesObjectsAssociatedWithFile && analysesObjectsAssociatedWithFile.count) {
            [self.analyses removeObjectsInArray:analysesObjectsAssociatedWithFile];
        }
    }
}

- (void)removeFromLocalAnalysisList:(NSNumber *)analysisId
{
    @synchronized(self)
    {
        __block INVAnalysis *analysis;
        [self.analyses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVAnalysis *temp = obj;
            if ([temp.analysisId isEqualToNumber:analysisId]) {
                analysis = obj;
                *stop = YES;
            }
        }];
        if (analysis) {
            [self.analyses removeObject:analysis];
        }
    }
}

- (void)addToLocalAnalysisList:(NSNumber *)analysisId
{
    @synchronized(self)
    {
        __block INVAnalysis *analysis;
        INVAnalysisArray analysesInProject = [self.analysisManager analysesForProject:self.projectId];
        [analysesInProject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVAnalysis *temp = obj;
            if ([temp.analysisId isEqualToNumber:analysisId]) {
                analysis = obj;
                *stop = YES;
            }
        }];
        if (analysis) {
            [self.analyses addObject:analysis];
        }
    }
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

                             if (self.showAnalysesForPkg) {
                                 if (tableViewCell.isAdded) {
                                     [self removeFromLocalAnalysisList:tableViewCell.contentId];
                                 }
                                 else {
                                     [self addToLocalAnalysisList:tableViewCell.contentId];
                                 }
                             }
                             else {
                                 if (tableViewCell.isAdded) {
                                     [self addToLocalAnalysisList:tableViewCell.contentId];
                                 }
                                 else {
                                     [self removeFromLocalAnalysisList:tableViewCell.contentId];
                                 }
                             }
                             [self.analysesDataSource updateWithDataArray:self.analyses forSection:SECTION_ANALYSESLIST];
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

#pragma mark - Helpers
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

@end
