//
//  INVRuleSetIncludedFilesViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleSetIncludedFilesViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;

@interface INVRuleSetIncludedFilesViewController ()
@property (nonatomic, strong)INVGenericTableViewDataSource* rsFilesDataSource;
@property (nonatomic,strong)INVGenericTableViewDataSource* projectFilesDataSource;
@property (nonatomic, strong) INVProjectManager* projectManager;
@property (nonatomic, strong) INVRulesManager* rulesManager;
@property (nonatomic,strong) INVFileMutableArray filesAssociatedWithRuleSet;
@property (nonatomic,strong) INVFileMutableArray filesNotAssociatedWithRuleSet;
@end

@implementation INVRuleSetIncludedFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    if (self.showFilesForRuleSetId) {
        self.tableView.dataSource = self.rsFilesDataSource;
        [self setHeaderViewWithHeading:NSLocalizedString(@"FILES_INCLUDED_IN_RULESET", nil)];

    }
    else {
        self.tableView.dataSource = self.projectFilesDataSource;
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
            [self.projectFilesDataSource updateWithDataArray:self.filesNotAssociatedWithRuleSet];
            [self.rsFilesDataSource updateWithDataArray:self.filesAssociatedWithRuleSet];
            
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
    [headerView setBackgroundColor:[UIColor clearColor]];
    
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

-(INVFileMutableArray)filesAssociatedWithRuleSet {
    if (!_filesAssociatedWithRuleSet) {
        _filesAssociatedWithRuleSet = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _filesAssociatedWithRuleSet;
}

-(INVFileMutableArray)filesNotAssociatedWithRuleSet {
    if (!_filesNotAssociatedWithRuleSet) {
        _filesNotAssociatedWithRuleSet = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _filesNotAssociatedWithRuleSet;
}


-(INVGenericTableViewDataSource*)projectFilesDataSource {
    if (!_projectFilesDataSource) {
        
        _projectFilesDataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:self.filesNotAssociatedWithRuleSet];
        
        INV_CellConfigurationBlock cellConfigurationBlock = ^(UITableViewCell *cell,INVFile* file,NSIndexPath* indexPath ){
            cell.textLabel.text = file.fileName;
            
            NSString* versionStr = NSLocalizedString(@"VERSION", nil);
            NSString* versionAttrStr =[NSString stringWithFormat:@"%@ : %@",versionStr,file.version ];
            cell.detailTextLabel.text = versionAttrStr;
            
        };
        [_projectFilesDataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectFileCell" configureBlock:cellConfigurationBlock];
    }
    return _projectFilesDataSource;
}

-(INVGenericTableViewDataSource*)rsFilesDataSource {
    if (!_rsFilesDataSource) {
        _rsFilesDataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:self.filesAssociatedWithRuleSet];
        
        INV_CellConfigurationBlock cellConfigurationBlock = ^(UITableViewCell *cell,INVFile* file,NSIndexPath* indexPath ){
            cell.textLabel.text = file.fileName;
            
            NSString* versionStr = NSLocalizedString(@"VERSION", nil);
            NSString* versionAttrStr =[NSString stringWithFormat:@"%@ : %@",versionStr,file.version ];
            cell.detailTextLabel.text = versionAttrStr;
            
        };
        [_rsFilesDataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectFileCell" configureBlock:cellConfigurationBlock];
    }
    return _rsFilesDataSource;
}

#pragma mark - helpers
-(void)updateFilesList {
    self.filesNotAssociatedWithRuleSet = [self.projectManager.projectFiles mutableCopy];
    NSArray* filesMasterIdsInRuleSet = [self.rulesManager fileMasterIdsForRuleSetId:self.ruleSetId];
    self.filesAssociatedWithRuleSet = [[self.projectManager filesForMasterIds:filesMasterIdsInRuleSet]mutableCopy];
    if (self.filesAssociatedWithRuleSet && self.filesAssociatedWithRuleSet.count) {
         [self.filesNotAssociatedWithRuleSet removeObjectsInArray:self.filesAssociatedWithRuleSet];
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
