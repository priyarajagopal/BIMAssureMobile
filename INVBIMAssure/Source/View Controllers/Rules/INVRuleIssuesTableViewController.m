//
//  INVRuleIssuesTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 3/30/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleIssuesTableViewController.h"
#import "INVRuleInstanceGeneralTypeParamTableViewCell.h"
#import "INVGenericTableViewDataSource.h"
#import "INVTextFieldTableViewCell.h"
#import "INVRuleParameterParser.h"
#import "NSArray+INVCustomizations.h"

static const NSInteger SECTION_RULEINSTANCEISSUES = 0;
static const NSInteger SECTION_RULEINSTANCEPARAM = 1;

static const NSInteger ROW_RULEINSTANCEDETAILS_NAME = 0;

static const NSInteger DEFAULT_CELL_HEIGHT = 50;

@interface INVRuleIssuesTableViewController ()
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, copy) NSMutableArray *originalRuleInstanceActualParams;
@property (nonatomic, copy) INVRuleIssueMutableArray ruleIssues;
@property (nonatomic, copy) NSString *ruleName;
@property (nonatomic, strong) INVRuleParameterParser *ruleParamParser;
@end

@implementation INVRuleIssuesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = nil;
    self.ruleParamParser = [INVRuleParameterParser instance];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"RuleIssueTVC"];

    UINib *parameterArrayNib =
        [UINib nibWithNibName:NSStringFromClass([INVRuleInstanceGeneralTypeParamTableViewCell class]) bundle:nil];
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
        self.ruleName = self.ruleResult.ruleName;
        
        if (self.buildingElementId) {
            [self setupTableViewDataSource];
             [self fetchIssuesForBuildingElement]; // use issues at building level
            
        }
        else {
            self.ruleIssues = [self.ruleResult.issues mutableCopy]; // use rule level issues
            [self setupTableViewDataSource];
        }
        
    }
    else {
#warning todo Display an alert with error message
        INVLogError(@"Cannot fetch issue details for rule result %@ and buidling element %@",
            self.ruleResult.analysisRunResultId, self.buildingElementId);
    }
    [self fetchRuleInstanceAndDefinition];
    
    self.title = self.ruleName;
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
    [self.dataSource updateWithDataArray:self.originalRuleInstanceActualParams forSection:SECTION_RULEINSTANCEPARAM];

    INV_CellConfigurationBlock cellConfigurationBlockForRuleParams =
        ^(INVRuleInstanceGeneralTypeParamTableViewCell *cell, INVActualParamKeyValuePair actualParam, NSIndexPath *indexPath) {
            if ([actualParam[INVActualParamType] isEqual:@(INVParameterTypeElementType)] &&
                ![actualParam[INVActualParamName] isEqualToString:@""]) {
                NSString *elementTypeId = actualParam[INVActualParamValue];

                [self.globalDataManager.invServerClient
                    fetchBATypeDisplayNameForCode:elementTypeId
                              withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                  NSString *title = [[result valueForKeyPath:@"hits.@unionOfArrays.fields.name"] firstObject];
                                  if (title) {
                                      actualParam[INVActualParamValue] = title;
                                      actualParam[INVActualParamName] = @"";
                                      [cell setActualParamDictionary:actualParam];
                                  }

                              }];
            }

            if ([actualParam[INVActualParamType] isEqual:@(INVParameterTypeElementType)]) {
                if ([actualParam[INVActualParamName] isEqualToString:@""]) {
                    [cell setActualParamDictionary:actualParam];
                }
            }
            else {
                [cell setActualParamDictionary:actualParam];
            }
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

- (void)fetchRuleInstanceAndDefinition
{
    [self.globalDataManager.invServerClient
        getRuleInstanceForRuleInstanceId:self.ruleResult.ruleId
                     WithCompletionBlock:^(INVRuleInstance *instance, INVEmpireMobileError *error) {
                         INV_ALWAYS:

                         INV_SUCCESS:
                             [self fetchRuleDefinitionForRuleId:instance.ruleDefId];

                         INV_ERROR:
                             INVLogError(@"%@", error);

                             UIAlertController *errController = [[UIAlertController alloc]
                                 initWithErrorMessage:NSLocalizedString(@"ERROR_ISSUES_FOR_BUILDING_ELEMENT_LOAD", nil),
                                 error.code.integerValue];
                             [self presentViewController:errController animated:YES completion:nil];
                     }];
}

- (void)fetchRuleDefinitionForRuleId:(NSNumber *)ruleDefId
{
    [self.globalDataManager.invServerClient
        getRuleDefinitionForRuleId:ruleDefId
               WithCompletionBlock:^(INVRule *ruleDefinition, INVEmpireMobileError *error) {

                   INV_ALWAYS:

                   INV_SUCCESS : {
                       NSArray *params =
                           [self.ruleParamParser transformRuleInstanceParamsToArray:self.ruleResult definition:ruleDefinition];

                       //  [self postProcessActualParams:params];
                       [self.originalRuleInstanceActualParams setArray:params];
                       [self.dataSource updateWithDataArray:self.originalRuleInstanceActualParams
                                                 forSection:SECTION_RULEINSTANCEPARAM];

                       [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                   }

                   INV_ERROR:
                       INVLogError(@"%@", error);

                       UIAlertController *errController = [[UIAlertController alloc]
                           initWithErrorMessage:NSLocalizedString(@"ERROR_ISSUES_FOR_BUILDING_ELEMENT_LOAD", nil),
                           error.code.integerValue];
                       [self presentViewController:errController animated:YES completion:nil];
               }];
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


@end
