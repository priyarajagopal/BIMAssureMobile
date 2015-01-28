//
//  INVRuleSetIncludedFilesViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleSetFilesListTableViewController.h"
#import "INVGeneralAddRemoveTableViewCell.h"
#import "INVPagingManager+PackageMasterListing.h"

static const NSInteger SECTION_RULESETFILES = 0;
static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;
static const NSInteger DEFAULT_FETCH_PAGE_SIZE = 20;

@interface INVRuleSetFilesListTableViewController () <INVGeneralAddRemoveTableViewCellAcionDelegate,INVPagingManagerDelegate>
@property (nonatomic,strong)INVGenericTableViewDataSource* filesDataSource;
@property (nonatomic, strong) INVProjectManager* projectManager;
@property (nonatomic, strong) INVRulesManager* rulesManager;
@property (nonatomic, strong) INVPackageMutableArray files;
@property (nonatomic, assign) BOOL observersAdded;
@property (nonatomic,strong)INVPagingManager* packagesPagingManager;
@end

@implementation INVRuleSetFilesListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.packagesPagingManager = [[INVPagingManager alloc]initWithPageSize:DEFAULT_FETCH_PAGE_SIZE delegate:self];
    UINib* projectCellNib = [UINib nibWithNibName:@"INVGeneralAddRemoveTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:projectCellNib forCellReuseIdentifier:@"ProjectFileCell"];
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    
    if (self.showFilesForRuleSetId) {
         [self setHeaderViewWithHeading:NSLocalizedString(@"FILES_INCLUDED_IN_RULESET", nil)];
    }
    else {
        [self setHeaderViewWithHeading:NSLocalizedString(@"FILES_NOT_INCLUDED_IN_RULESET", nil)];
    }
    self.refreshControl = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.dataSource = self.filesDataSource;
    
    [self addObserversForFileMoveNotification];
    [self fetchPackagesFromCurrentOffset];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObserversForFileMoveNotification];
    if (self.showFilesForRuleSetId) {
        [self pushAddedPkgMastersForRuleSetIdToServer];
        [self pushRemovedPkgMastersForRuleSetIdToServer];
    }
    self.projectManager = nil;
    self.rulesManager = nil;
    self.tableView.dataSource = nil;
    self.filesDataSource = nil;
    self.files = nil;
}

#pragma mark - public
-(void)resetFileEntries {
    [self updateFilesListFromServer];
    [self.filesDataSource updateWithDataArray:self.files forSection:SECTION_RULESETFILES];
    [self.tableView reloadData];
}

#pragma mark - server side
/*
-(void)fetchListOfProjectFiles {
    [self showLoadProgress];
    [self.globalDataManager.invServerClient getAllPkgMastersForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        if (!error) {
            [self fetchProjectFilesForRuleSetId];
        }
        else {

            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_PKGMASTER_MEMBERSHIP_LOAD", nil),error.code]];
            [self presentViewController:errController animated:YES completion:^{
                
            }];
        }
    }];
}
*/
-(void)fetchProjectFilesForRuleSetId {
    [self showLoadProgress];
    [self.globalDataManager.invServerClient getAllPkgMastersForRuleSet:self.ruleSetId WithCompletionBlock:^(INVEmpireMobileError *error) {
         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        if (!error) {
            [self updateFilesListFromServer ];
            [self.filesDataSource updateWithDataArray:self.files forSection:SECTION_RULESETFILES];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
        }
        else {
            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_PKGMASTER_MEMBERSHIP_LOAD", nil),error.code]];
            [self presentViewController:errController animated:YES completion:^{
                
            }];
        }
    }];
}

-(void) fetchPackagesFromCurrentOffset {
    [self showLoadProgress];
    [self.packagesPagingManager fetchPackageMastersFromCurrentOffsetForProject:self.projectId];
}


-(void)pushAddedPkgMastersForRuleSetIdToServer {
    NSSet* currentPkgMastersForRuleSet = [self.globalDataManager.invServerClient.rulesManager pkgMastersForRuleSetId:self.ruleSetId];
    NSMutableSet* updatedPkgMasterIds = [[NSMutableSet alloc]initWithCapacity:0];
    [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVPackage* package = obj;
        [updatedPkgMasterIds addObject:package.packageId];
    }];
    
    [updatedPkgMasterIds minusSet:currentPkgMastersForRuleSet];
    
    [self.globalDataManager.invServerClient addToRuleSet:self.ruleSetId pkgMasters:[updatedPkgMasterIds allObjects] withCompletionBlock:^(INVEmpireMobileError *error) {
        if (error) {
            INVLogError(@"Failed to add pkg masters %@ for rule set %@ with error %@",updatedPkgMasterIds,self.ruleSetId,error);
        }
        else {
            INVLogDebug(@"Succesfully added pkg master %@ for rule set %@", updatedPkgMasterIds, self.ruleSetId);
        }
    }];
    
}

-(void)pushRemovedPkgMastersForRuleSetIdToServer {
    NSMutableSet* currentPkgMastersForRuleSet = [[self.globalDataManager.invServerClient.rulesManager pkgMastersForRuleSetId:self.ruleSetId]mutableCopy];
    NSMutableSet* updatedPkgMasterIds = [[NSMutableSet alloc]initWithCapacity:0];
    [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVPackage* package = obj;
        [updatedPkgMasterIds addObject:package.packageId];
    }];
    
    [currentPkgMastersForRuleSet minusSet:updatedPkgMasterIds];
    
    [currentPkgMastersForRuleSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSNumber* pkgMasterToRemove = obj;
        [self.globalDataManager.invServerClient removeFromRuleSet:self.ruleSetId pkgMaster:pkgMasterToRemove  withCompletionBlock:^(INVEmpireMobileError *error) {
            if (error ) {
                INVLogError(@"Failed to remove pkg masters  %@ for rule set %@ with error %@",pkgMasterToRemove,self.ruleSetId, error);
            }
            else {
                INVLogDebug(@"Succesfully removed pkg master %@ for rule set %@", updatedPkgMasterIds,self.ruleSetId);
            }
        }];

    }];
    
    
}

#pragma mark - INVPagingManagerDelegate
-(void)onFetchedDataAtOffset:(NSInteger)offset pageSize:(NSInteger)size withError:(INVEmpireMobileError*)error {
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
    
    if (!error) {
        [self fetchProjectFilesForRuleSetId];
    }
    else {
        
        UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_PKGMASTER_MEMBERSHIP_LOAD", nil),error.code]];
        [self presentViewController:errController animated:YES completion:^{
            
        }];
    }
    
}


#pragma mark - UITableView
-(void)setHeaderViewWithHeading:(NSString*)heading {
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.tableView.frame), DEFAULT_HEADER_HEIGHT)];
    UIColor * medGreyColor = [UIColor colorWithRed:225.0/255 green:225.0/255 blue:225.0/255 alpha:1.0];    
    [headerView setBackgroundColor:medGreyColor];
    
    UILabel* headingLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,10, CGRectGetWidth(headerView.frame)-20, DEFAULT_HEADER_HEIGHT )];
    headingLabel.text  = heading;
    headingLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [headerView addSubview:headingLabel];
    
    [self.tableView setTableHeaderView:headerView];
}


#pragma mark - INVGeneralAddRemoveTableViewCellAcionDelegate
-(void)addRemoveFileTapped:(INVGeneralAddRemoveTableViewCell*)sender {
    if (sender.isAdded) {
     
    }
}


#pragma mark - accessors
-(INVProjectManager*)projectManager {
    if (!_projectManager) {
        _projectManager = self.globalDataManager.invServerClient.projectManager;
    }
    return _projectManager;
}

-(INVRulesManager*)rulesManager {
    if (!_rulesManager) {
        _rulesManager = self.globalDataManager.invServerClient.rulesManager;
    }
    return _rulesManager;
}

-(INVPackageMutableArray)files {
    if (!_files) {
        _files = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _files;
}

-(INVGenericTableViewDataSource*)filesDataSource {
    if (!_filesDataSource) {
        
        _filesDataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:self.files forSection:SECTION_RULESETFILES forTableView:self.tableView];
        
        INV_CellConfigurationBlock cellConfigurationBlock = ^(INVGeneralAddRemoveTableViewCell *cell,INVPackage* file,NSIndexPath* indexPath ){
            cell.name.text = file.packageName;
            cell.isAdded = self.showFilesForRuleSetId;
            cell.contentId = file.packageId;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        };
        [_filesDataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectFileCell" configureBlock:cellConfigurationBlock];
    }
    return _filesDataSource;
}

#pragma mark - Observer Handling
-(void)addObserversForFileMoveNotification {
    if (self.observersAdded) {
        return;
    }
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserverForName:INV_NotificationAddRemoveCell object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary* userInfo = note.userInfo;
        INVGeneralAddRemoveTableViewCell* tableViewCell = userInfo[@"AddRemoveCell"];
        
        if (self.showFilesForRuleSetId) {
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
        [self.filesDataSource updateWithDataArray:self.files forSection:SECTION_RULESETFILES];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    }];
    self.observersAdded = YES;
}

-(void)removeObserversForFileMoveNotification {
    if (!self.observersAdded) {
        return;
    }
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:INV_NotificationAddRemoveCell object:nil];
    self.observersAdded = NO;
}




#pragma mark - helpers
-(void)updateFilesListFromServer {
    self.files = [[self.projectManager  packagesForProjectId:self.projectId] mutableCopy];
    NSSet* filesMasterIdsInRuleSet = [self.rulesManager pkgMastersForRuleSetId:self.ruleSetId];
    INVPackageMutableArray filesAssociatedWithRuleSet = [[self.projectManager packageFilesForMasterIds:[filesMasterIdsInRuleSet allObjects]]mutableCopy];
    if (self.showFilesForRuleSetId) {
        self.files = filesAssociatedWithRuleSet;
    }
    else {
        if (filesAssociatedWithRuleSet && filesAssociatedWithRuleSet.count) {
            [self.files removeObjectsInArray:filesAssociatedWithRuleSet];
        }
    }
}

-(void)removeFromLocalFileList:(NSNumber*)fileMasterId {
    @synchronized (self) {
        __block INVPackage* file;
        [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVPackage* temp = obj;
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

-(void)addToLocalFileList:(NSNumber*)fileMasterId {
    @synchronized (self) {
        __block INVPackage* file;
        NSArray* packages = [self.projectManager packagesForProjectId:self.projectId];
        [packages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVPackage* temp = obj;
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

-(void) showLoadProgress {
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.files.count - indexPath.row ==  DEFAULT_FETCH_PAGE_SIZE/4) {
        INVLogDebug(@"Will fetch next batch");
        
        [self fetchPackagesFromCurrentOffset];
    }
}


@end
