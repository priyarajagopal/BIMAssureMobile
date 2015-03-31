//
//  INVRuleIssuesTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 3/30/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleIssuesTableViewController.h"
#import "INVRuleInstanceStringParamTableViewCell.h"
#import "INVGenericTableViewDataSource.h"
#import "INVTextFieldTableViewCell.h"

static const NSInteger SECTION_RULEINSTANCEISSUES = 0;
static const NSInteger SECTION_RULEINSTANCEPARAM = 1;

static const NSInteger ROW_RULEINSTANCEDETAILS_NAME = 0;

static const NSInteger DEFAULT_CELL_HEIGHT = 50;

@interface INVRuleIssuesTableViewController ()
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, copy) NSMutableArray *originalRuleInstanceActualParams;
@property (nonatomic, copy) INVRuleIssueMutableArray ruleIssues;
@property (nonatomic, copy) NSString *ruleName;
@end

@implementation INVRuleIssuesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = nil;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"RuleIssueTVC"];

    UINib *parameterArrayNib =
        [UINib nibWithNibName:NSStringFromClass([INVRuleInstanceStringParamTableViewCell class]) bundle:nil];
    [self.tableView registerNib:parameterArrayNib forCellReuseIdentifier:@"RuleInstanceParamCell"];

    self.refreshControl = nil;

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.ruleResult) {
        [self processRuleResult];
        [self setupTableViewDataSource];

        if (self.buildingElementId) {
            [self fetchIssuesForBuildingElement];
        }

        self.title = self.ruleName;
    }
    else {
#warning todo Display an alert with error message
        INVLogError(@"Cannot fetch issue details for rule result %@ and buidling element %@",
            self.ruleResult.analysisRunResultId, self.buildingElementId);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.originalRuleInstanceActualParams = nil;
    self.tableView.dataSource = nil;
    self.dataSource = nil;
}

#pragma mark - Manage Table View Data Sources

- (void)setupTableViewDataSource
{
    // rule issues
    [self setupRuleIssuesDataSource];

    // The actual
    [self setupRuleInstanceActualParamsDataSource];

    self.tableView.dataSource = self.dataSource;
}

- (void)setupRuleIssuesDataSource
{
    self.ruleIssues = self.ruleIssues ?: [@[] mutableCopy];
    [self.dataSource updateWithDataArray:self.ruleIssues forSection:SECTION_RULEINSTANCEISSUES];

    INV_CellConfigurationBlock cellConfigurationBlockForRuleIssues =
        ^(INVTextFieldTableViewCell *cell, INVRuleIssue *issue, NSIndexPath *indexPath) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.text = issue.issueDescription;
            cell.textLabel.numberOfLines = 0;

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        };

    [self.dataSource registerCellWithIdentifier:@"RuleIssueTVC"
                                 configureBlock:cellConfigurationBlockForRuleIssues
                                     forSection:SECTION_RULEINSTANCEISSUES];
}

- (void)setupRuleInstanceActualParamsDataSource
{
    self.originalRuleInstanceActualParams = self.originalRuleInstanceActualParams ?: [@[] mutableCopy];
    [self.dataSource updateWithDataArray:self.originalRuleInstanceActualParams forSection:SECTION_RULEINSTANCEPARAM];

    INV_CellConfigurationBlock cellConfigurationBlockForRuleParams =
        ^(INVRuleInstanceStringParamTableViewCell *cell, INVActualParamKeyValuePair actualParam, NSIndexPath *indexPath) {
            cell.tintColor = [UIColor whiteColor];

            [cell setActualParamDictionary:actualParam];
            [cell setUserInteractionEnabled:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        };
    [self.dataSource registerCellWithIdentifier:@"RuleInstanceParamCell"
                                 configureBlock:cellConfigurationBlockForRuleParams
                                     forSection:SECTION_RULEINSTANCEPARAM];
}

#pragma mark - server side
- (void)fetchIssuesForBuildingElement
{
    [self.globalDataManager.invServerClient
        fetchIssuesForBuildingElement:self.buildingElementId
                         forRunResult:self.ruleResult.analysisRunResultId
                  WithCompletionBlock:^(INVRuleIssueArray result, INVEmpireMobileError *error) {
                      INV_ALWAYS:
                          [self.hud hide:YES];

                      INV_SUCCESS:
                          self.ruleIssues = [result mutableCopy];
                          [self.dataSource updateWithDataArray:self.ruleIssues forSection:SECTION_RULEINSTANCEISSUES];

                          [self.tableView reloadData];

                      INV_ERROR:
                          INVLogError(@"%@", error);

                          UIAlertController *errController = [[UIAlertController alloc]
                              initWithErrorMessage:NSLocalizedString(@"ERROR_ISSUES_FOR_BUILDING_ELEMENT_LOAD", nil),
                              error.code.integerValue];
                          [self presentViewController:errController animated:YES completion:nil];
                  }];
    [self.tableView reloadData];
}

#pragma mark - accessors
- (INVRuleIssueMutableArray)ruleIssues
{
    if (!_ruleIssues) {
        _ruleIssues = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _ruleIssues;
}

- (NSMutableArray *)originalRuleInstanceActualParams
{
    if (!_originalRuleInstanceActualParams) {
        _originalRuleInstanceActualParams = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _originalRuleInstanceActualParams;
}

- (INVGenericTableViewDataSource *)dataSource
{
    // Return the right object depending on whether rule instance is modified or a new rule instance is created
    if (!_dataSource) {
        _dataSource =
            [[INVGenericTableViewDataSource alloc] initWithDataArray:nil forSection:NSNotFound forTableView:self.tableView];
    }
    return _dataSource;
}

#pragma mark - helpers
- (void)processRuleResult
{
    INVRuleInstanceActualParamDictionary actualParams = self.ruleResult.actualParameters;
    [self transformRuleInstanceActualParamsToArray:actualParams];
    self.ruleName = self.ruleResult.ruleName;
}

- (void)transformRuleInstanceActualParamsToArray:(INVRuleInstanceActualParamDictionary)actualParameters
{
    [actualParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        INVRuleInstanceActualParamDictionary valueDict = (INVRuleInstanceActualParamDictionary) obj;
        NSDictionary *entry = @{ INVActualParamDisplayName : key, INVActualParamValue : valueDict[@"value"] };

        [self.originalRuleInstanceActualParams addObject:entry];

    }];
}

@end
