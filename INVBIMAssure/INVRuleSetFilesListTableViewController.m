//
//  INVRuleSetIncludedFilesViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleSetFilesListTableViewController.h"
#import "INVManageProjectFileTableViewCell.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;

@interface INVRuleSetFilesListTableViewController ()
@property (nonatomic,strong)INVGenericTableViewDataSource* filesDataSource;

@property (nonatomic, strong) INVProjectManager* projectManager;
@property (nonatomic, strong) INVRulesManager* rulesManager;
@property (nonatomic,strong) INVFileMutableArray files;
@end

@implementation INVRuleSetFilesListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINib* projectCellNib = [UINib nibWithNibName:@"INVManageProjectFileTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
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
    [self fetchListOfProjectFiles];
    [self fetchProjectFilesForRuleSetId];
}


#pragma mark - server side
-(void)fetchListOfProjectFiles {
    [self.globalDataManager.invServerClient getAllFilesForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
            [self updateFilesList];
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
            [self updateFilesList ];
            [self.filesDataSource updateWithDataArray:self.files];
            [self.tableView reloadData];
        }
        else {
#warning - display error
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
        
        _filesDataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:self.files];
        
        INV_CellConfigurationBlock cellConfigurationBlock = ^(INVManageProjectFileTableViewCell *cell,INVFile* file,NSIndexPath* indexPath ){
            cell.fileName.text = file.fileName;
            cell.isInRuleSet = self.showFilesForRuleSetId;
            
        };
        [_filesDataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectFileCell" configureBlock:cellConfigurationBlock];
    }
    return _filesDataSource;
}

#pragma mark - helpers
-(void)updateFilesList {
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
