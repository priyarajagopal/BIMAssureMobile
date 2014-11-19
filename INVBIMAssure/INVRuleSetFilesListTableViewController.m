//
//  INVRuleSetIncludedFilesViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleSetFilesListTableViewController.h"
#import "INVGeneralAddRemoveTableViewCell.h"

static const NSInteger SECTION_RULESETFILES = 0;
static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;

@interface INVRuleSetFilesListTableViewController () <INVGeneralAddRemoveTableViewCellAcionDelegate>
@property (nonatomic,strong)INVGenericTableViewDataSource* filesDataSource;
@property (nonatomic, strong) INVProjectManager* projectManager;
@property (nonatomic, strong) INVRulesManager* rulesManager;
@property (nonatomic, strong) INVFileMutableArray files;
@property (nonatomic, assign) BOOL observersAdded;
@end

@implementation INVRuleSetFilesListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UINib* projectCellNib = [UINib nibWithNibName:@"INVGeneralAddRemoveTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:projectCellNib forCellReuseIdentifier:@"ProjectFileCell"];
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    if (self.showFilesForRuleSetId) {
        self.tableView.dataSource = self.filesDataSource;
        [self setHeaderViewWithHeading:NSLocalizedString(@"FILES_INCLUDED_IN_RULESET", nil)];
    }
    else {
        self.tableView.dataSource = self.filesDataSource;
        [self setHeaderViewWithHeading:NSLocalizedString(@"FILES_NOT_INCLUDED_IN_RULESET", nil)];
    }
    self.refreshControl = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    [self addObserversForFileMoveNotification];
    [self fetchListOfProjectFiles];
    [self fetchProjectFilesForRuleSetId];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObserversForFileMoveNotification];
    if (self.showFilesForRuleSetId) {
        [self pushUpdatedProjectFilesForRuleSetIdToServer];
    }
}

#pragma mark - public
-(void)resetFileEntries {
    [self updateFilesListFromServer];
    [self.filesDataSource updateWithDataArray:self.files forSection:SECTION_RULESETFILES];
    [self.tableView reloadData];
}

#pragma mark - server side
-(void)fetchListOfProjectFiles {
    [self.globalDataManager.invServerClient getAllFilesForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
            [self updateFilesListFromServer];
            [self.filesDataSource updateWithDataArray:self.files forSection:SECTION_RULESETFILES];
            [self.tableView reloadData];
        }
        else {
#warning - display error
        }
    }];
}

-(void)fetchProjectFilesForRuleSetId {
    [self.globalDataManager.invServerClient getAllFileMastersForRuleSet:self.ruleSetId WithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
            [self updateFilesListFromServer ];
            [self.filesDataSource updateWithDataArray:self.files forSection:SECTION_RULESETFILES];
            [self.tableView reloadData];
        }
        else {
#warning - display error
        }
    }];
}

-(void)pushUpdatedProjectFilesForRuleSetIdToServer {
    NSMutableArray* fileMasterIds = [[NSMutableArray alloc]initWithCapacity:0];
    [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVFile* file = obj;
        [fileMasterIds addObject:file.fileId];
    }];
    [self.globalDataManager.invServerClient updateRuleSet:self.ruleSetId withFileMasters:fileMasterIds withCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (error) {
#warning Show error alert
        }
    }];
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

-(INVFileMutableArray)files {
    if (!_files) {
        _files = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _files;
}

-(INVGenericTableViewDataSource*)filesDataSource {
    if (!_filesDataSource) {
        
        _filesDataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:self.files forSection:SECTION_RULESETFILES];
        
        INV_CellConfigurationBlock cellConfigurationBlock = ^(INVGeneralAddRemoveTableViewCell *cell,INVFile* file,NSIndexPath* indexPath ){
            cell.name.text = file.fileName;
            cell.isAdded = self.showFilesForRuleSetId;
            cell.contentId = file.fileId;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        };
        [_filesDataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectFileCell" configureBlock:cellConfigurationBlock];
    }
    return _filesDataSource;
}

#pragma mark - helpers
-(void)updateFilesListFromServer {
    self.files = [self.projectManager.projectFiles mutableCopy];
    NSArray* filesMasterIdsInRuleSet = [self.rulesManager fileMasterIdsForRuleSetId:self.ruleSetId];
    INVFileMutableArray filesAssociatedWithRuleSet = [[self.projectManager filesForMasterIds:filesMasterIdsInRuleSet]mutableCopy];
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
        __block INVFile* file;
        [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVFile* temp = obj;
            if ([temp.fileId isEqualToNumber:fileMasterId]) {
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
        __block INVFile* file;
        [self.projectManager.projectFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVFile* temp = obj;
            if ([temp.fileId isEqualToNumber:fileMasterId]) {
                file = obj;
                *stop = YES;
            }
        }];
        if (file) {
            [self.files addObject:file];
        }
    }
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
        [self.tableView reloadData];
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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 
}


@end
