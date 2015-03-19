//
//  INVRuleInstanceTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewController.h"
#import "INVRuleInstanceActualParamTableViewCell.h"
#import "INVRuleInstanceOverviewTableViewCell.h"
#import "INVRuleInstanceNameTableViewCell.h"

static const NSInteger SECTION_RULEINSTANCEDETAILS = 0;
static const NSInteger SECTION_RULEINSTANCEACTUALPARAM = 1;
static const NSInteger ROW_RULEINSTANCEDETAILS_NAME = 0;
static const NSInteger ROW_RULEINSTANCEDETAILS_OVERVIEW = 1;

static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_OVERVIEW_CELL_HEIGHT = 175;

/**
 Dictionary of Name-Value pairs corresponding to the actual parameters. The supported keys are  INV_ActualParamName and
 INV_ActualParamValue
 */
typedef NSDictionary *INV_ActualParamKeyValuePair;
static NSString *INV_ActualParamName = @"Name";
static NSString *INV_ActualParamValue = @"Value";

@interface INVRuleInstanceTableViewController () <INVRuleInstanceActualParamTableViewCellDelegate,
    INVRuleInstanceOverviewTableViewCellDelegate>
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, strong) INVRulesManager *rulesManager;

@property (nonatomic, strong) NSMutableArray *intermediateRuleInstanceActualParams; // Array of INV_ActualParamKeyValuePair
                                                                                    // objects transformed from the array params
                                                                                    // dictionary fetched from server
@property (nonatomic, strong) NSString *intermediateRuleOverview;

// rule definition unused at this time. Eventually use
@property (nonatomic, strong) INVRule *ruleDefinition;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveBarButton;
@property (nonatomic, weak) UITableViewCell *ruleInstanceCellBeingEdited;

@end

@implementation INVRuleInstanceTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"GIVE NAME OF RULE INSTANCE HERE", nil);

    UINib *riNib =
        [UINib nibWithNibName:@"INVRuleInstanceActualParamTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:riNib forCellReuseIdentifier:@"RuleInstanceDetailCell"];

    UINib *rioNib =
        [UINib nibWithNibName:@"INVRuleInstanceOverviewTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:rioNib forCellReuseIdentifier:@"RuleInstanceOverviewTVC"];

    UINib *rinNib = [UINib nibWithNibName:@"INVRuleInstanceNameTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:rinNib forCellReuseIdentifier:@"RuleInstanceNameTVC"];

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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
    [self.saveBarButton setEnabled:NO];

    [self setupTableViewDataSource];

    if (self.ruleInstanceId) {
        [self fetchRuleInstance];
    }
    else if (self.ruleId) {
        [self fetchRuleDefinitionForRuleId:self.ruleId];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.rulesManager = nil;
    self.intermediateRuleInstanceActualParams = nil;
    self.ruleDefinition = nil;
    self.saveBarButton = nil;
    self.tableView.dataSource = nil;
    self.dataSource = nil;
}

- (void)setupTableFooter
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Manage Table View Data Sources

- (void)setupTableViewDataSource
{
    // rule name
    [self setupRuleNameDataSource];

    // rule overview
    [self setupRuleOverviewDataSource];

    // The actual params if we are editing a rule instance
    [self setupRuleInstanceActualParamsDataSource];

    self.tableView.dataSource = self.dataSource;
}

- (void)setupRuleNameDataSource
{
    NSIndexPath *indexPathForRuleName =
        [NSIndexPath indexPathForRow:ROW_RULEINSTANCEDETAILS_NAME inSection:SECTION_RULEINSTANCEDETAILS];
    INV_CellConfigurationBlock cellConfigurationBlockForRuleName =
        ^(INVRuleInstanceNameTableViewCell *cell, NSString *ruleName, NSIndexPath *indexPath) {
            cell.ruleName.text = ruleName;
            [cell.ruleName setUserInteractionEnabled:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        };
    [self.dataSource registerCellWithIdentifier:@"RuleInstanceNameTVC"
                                 configureBlock:cellConfigurationBlockForRuleName
                                   forIndexPath:indexPathForRuleName];
}

- (void)setupRuleOverviewDataSource
{
    NSIndexPath *indexPathForRuleOverview =
        [NSIndexPath indexPathForRow:ROW_RULEINSTANCEDETAILS_OVERVIEW inSection:SECTION_RULEINSTANCEDETAILS];

    INV_CellConfigurationBlock cellConfigurationBlockForRuleOverview =
        ^(INVRuleInstanceOverviewTableViewCell *cell, NSString *overview, NSIndexPath *indexPath) {
            cell.ruleDescription.text = overview;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.delegate = self;
        };
    [self.dataSource registerCellWithIdentifier:@"RuleInstanceOverviewTVC"
                                 configureBlock:cellConfigurationBlockForRuleOverview
                                   forIndexPath:indexPathForRuleOverview];
}

- (void)setupRuleInstanceActualParamsDataSource
{
    [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams forSection:SECTION_RULEINSTANCEACTUALPARAM];
    INV_CellConfigurationBlock cellConfigurationBlock =
        ^(INVRuleInstanceActualParamTableViewCell *cell, NSDictionary *KVPair, NSIndexPath *indexPath) {
            cell.ruleInstanceKey.text = KVPair[INV_ActualParamName];
            cell.ruleInstanceValue.text = KVPair[INV_ActualParamValue];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        };
    [self.dataSource registerCellWithIdentifier:@"RuleInstanceDetailCell"
                                 configureBlock:cellConfigurationBlock
                                     forSection:SECTION_RULEINSTANCEACTUALPARAM];
}

#pragma mark - server side
- (void)fetchRuleInstance
{
    if (!self.analysesId || !self.ruleInstanceId) {
#warning Show an error alert or a default page
        INVLogError(
            @"Cannot fetch rule instance details for analyses %@ and RuleInstanceId %@", self.analysesId, self.ruleInstanceId);
    }
    else {
#warning If unlikely case that matchingRuleInstance was not fetched from the server due to any reason when this view was loaded , fetch it

        INVRuleInstance *ruleInstance =
            [self.globalDataManager.invServerClient.analysesManager ruleInstanceForRuleInstanceId:self.ruleInstanceId
                                                                                    forAnalysisId:self.analysesId];

        self.intermediateRuleOverview = ruleInstance.overview ? ruleInstance.overview : @"";
        self.ruleName = ruleInstance.ruleName;

        NSArray *ruleInfoArray = ruleInstance ? @[ self.ruleName, self.intermediateRuleOverview ] : [NSArray array];
        [self.dataSource updateWithDataArray:ruleInfoArray forSection:SECTION_RULEINSTANCEDETAILS];

        [self.globalDataManager.invServerClient
            getRuleDefinitionForRuleId:ruleInstance.ruleDefId
                   WithCompletionBlock:^(INVRule *rule, INVEmpireMobileError *error) {
                       [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

                       if (!error) {
                           [self transformRuleInstanceParamsToArray:ruleInstance definition:rule];
                           [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams
                                                     forSection:SECTION_RULEINSTANCEACTUALPARAM];
                       }
                       else {
                           if (error) {
                               UIAlertController *errController = [[UIAlertController alloc]
                                   initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_DEFINITION_FORINSTANCE_LOAD", nil),
                                   error.code.integerValue];
                               [self presentViewController:errController animated:YES completion:nil];
                           }
                       }

                       [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                       [self performSelectorOnMainThread:@selector(setupTableFooter) withObject:nil waitUntilDone:NO];
                   }];
    }

    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(setupTableFooter) withObject:nil waitUntilDone:NO];
}

- (void)fetchRuleDefinitionForRuleId:(NSNumber *)ruleId
{
    if (!ruleId) {
        INVLogDebug(@"Cannot fetch rule  definition for ruleId %@", ruleId);
    }
    else {
        [self showLoadProgress];
        [self.globalDataManager.invServerClient
            getRuleDefinitionForRuleId:ruleId
                   WithCompletionBlock:^(INVRule *rule, INVEmpireMobileError *error) {
                       [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

                       if (!error) {
                           self.ruleDefinition =
                               [self.globalDataManager.invServerClient.rulesManager ruleDefinitionForRuleId:ruleId];

                           INVRuleFormalParam *ruleFormalParam = self.ruleDefinition.formalParams;

                           [self transformRuleDefinitionParamsToArray:ruleFormalParam];
                           [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams
                                                     forSection:SECTION_RULEINSTANCEACTUALPARAM];
                       }
                       else {
                           if (error) {
                               UIAlertController *errController = [[UIAlertController alloc]
                                   initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_DEFINITION_FORINSTANCE_LOAD", nil),
                                   error.code.integerValue];
                               [self presentViewController:errController animated:YES completion:nil];
                           }
                       }

                       [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

                       [self performSelectorOnMainThread:@selector(setupTableFooter) withObject:nil waitUntilDone:NO];

                   }];
    }
}

- (void)sendCreateRuleInstanceRequestToServer
{
    INVRuleInstanceActualParamDictionary actualParam =
        [self transformRuleInstanceArrayToRuleInstanceParams:self.intermediateRuleInstanceActualParams];

    [self.globalDataManager.invServerClient
        createRuleForRuleDefinitionId:self.ruleId
                           inAnalysis:self.analysesId
                         withRuleName:self.ruleName
                       andDescription:self.intermediateRuleOverview
                  andActualParameters:actualParam
                  WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                      if (error) {
                          if (error) {
                              UIAlertController *errController = [[UIAlertController alloc]
                                  initWithErrorMessage:NSLocalizedString(@"ERROR_RULEINSTANCE_CREATE", nil),
                                  error.code.integerValue];
                              [self presentViewController:errController animated:YES completion:nil];
                          }
                      }
                      else {
                          [self showSuccessAlertMessage:NSLocalizedString(@"RULE_INSTANCE_CREATED_SUCCESS", nil) isCreated:YES];
                      }
                  }];
}

- (void)sendUpdatedRuleInstanceToServer
{
    INVRuleInstance *ruleInstance =
        [self.globalDataManager.invServerClient.rulesManager ruleInstanceForRuleInstanceId:self.ruleInstanceId
                                                                              forRuleSetId:self.analysesId];

    INVRuleInstanceActualParamDictionary actualParam =
        [self transformRuleInstanceArrayToRuleInstanceParams:self.intermediateRuleInstanceActualParams];

    [self.globalDataManager.invServerClient
        modifyRuleInstanceForRuleInstanceId:self.ruleInstanceId
                                  forRuleId:self.ruleId
                                 inAnalysis:self.analysesId
                               withRuleName:self.ruleName
                             andDescription:self.intermediateRuleOverview
                        andActualParameters:actualParam
                        WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                            if (error) {
                                if (error) {
                                    UIAlertController *errController = [[UIAlertController alloc]
                                        initWithErrorMessage:NSLocalizedString(@"ERROR_RULEINSTANCE_UPDATE", nil),
                                        error.code.integerValue];
                                    [self presentViewController:errController animated:YES completion:nil];
                                }
                            }
                            else {
                                [self showSuccessAlertMessage:NSLocalizedString(@"RULE_INSTANCE_UPDATED_SUCCESS", nil)
                                                    isCreated:NO];
                            }
                        }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CancelSegue"]) {
        [self resignFirstTextInputResponder];
    }
}

- (IBAction)done:(UIStoryboardSegue *)sender
{
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UIEventHandler

- (IBAction)onSaveRuleInstanceTapped:(UIBarButtonItem *)sender
{
    if (sender == self.saveBarButton) {
        [self.saveBarButton setEnabled:NO];

        [self resignFirstTextInputResponder];

        [self scrapeTableViewForUpdatedContent];

        if (self.ruleInstanceId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendUpdatedRuleInstanceToServer];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendCreateRuleInstanceRequestToServer];
            });
        }
    }
}

#pragma mark - INVRuleInstanceOverviewTableViewCellDelegate
- (void)onBeginEditingRuleInstanceOverviewField:(INVRuleInstanceOverviewTableViewCell *)sender
{
    [self.saveBarButton setEnabled:YES];
    self.ruleInstanceCellBeingEdited = sender;
}

- (void)onRuleInstanceOverviewUpdated:(INVRuleInstanceOverviewTableViewCell *)sender
{
    // Update the first responder
    [self makeFirstResponderTextFieldAtCellIndexPath:[NSIndexPath indexPathForRow:0 inSection:SECTION_RULEINSTANCEACTUALPARAM]];
}

#pragma mark - INVRuleInstanceActualParamTableViewCellDelegate
- (void)onBeginEditingRuleInstanceActualParamField:(INVRuleInstanceActualParamTableViewCell *)sender
{
    [self.saveBarButton setEnabled:YES];
    self.ruleInstanceCellBeingEdited = sender;
}

- (void)onRuleInstanceActualParamUpdated:(INVRuleInstanceActualParamTableViewCell *)sender
{
    INVRuleInstanceActualParamTableViewCell *editedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:editedCell];

    // 2) update the first responder
    if ([((INVRuleInstanceActualParamTableViewCell *) (self.ruleInstanceCellBeingEdited)).ruleInstanceValue isFirstResponder]) {
        if (self.intermediateRuleInstanceActualParams.count > indexPath.row + 1) {
            [self makeFirstResponderTextFieldAtCellIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1
                                                                                inSection:SECTION_RULEINSTANCEACTUALPARAM]];
        }
        if (self.intermediateRuleInstanceActualParams.count == indexPath.row + 1) {
            [self resignFirstTextInputResponder];
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_RULEINSTANCEDETAILS && indexPath.row == 1) {
        return DEFAULT_OVERVIEW_CELL_HEIGHT;
    }

    return DEFAULT_CELL_HEIGHT;
}

#pragma mark - helper

- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

- (void)showSuccessAlertMessage:(NSString *)message isCreated:(BOOL)created
{
    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action) {
                                   if (created) {
                                       if (self.delegate &&
                                           [self.delegate respondsToSelector:@selector(onRuleInstanceCreated:)]) {
                                           [self.delegate onRuleInstanceCreated:self];
                                       }
                                   }
                                   else {
                                       if (self.delegate &&
                                           [self.delegate respondsToSelector:@selector(onRuleInstanceModified:)]) {
                                           [self.delegate onRuleInstanceModified:self];
                                       }
                                   }
                               }];

    UIAlertController *successAlertController =
        [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [successAlertController addAction:action];

    [self presentViewController:successAlertController animated:YES completion:nil];
}

- (void)makeFirstResponderTextFieldAtCellIndexPath:(NSIndexPath *)indexPath
{
    INVRuleInstanceActualParamTableViewCell *cell =
        (INVRuleInstanceActualParamTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    self.ruleInstanceCellBeingEdited = cell;
    if (indexPath.section == SECTION_RULEINSTANCEDETAILS) {
        if (indexPath.row == ROW_RULEINSTANCEDETAILS_NAME) {
            [((INVRuleInstanceNameTableViewCell *) self.ruleInstanceCellBeingEdited).ruleName becomeFirstResponder];
        }
        else {
            [((INVRuleInstanceOverviewTableViewCell *) self.ruleInstanceCellBeingEdited).ruleDescription becomeFirstResponder];
        }
    }
    else if (indexPath.section == SECTION_RULEINSTANCEACTUALPARAM) {
        [((INVRuleInstanceActualParamTableViewCell *) self.ruleInstanceCellBeingEdited).ruleInstanceValue becomeFirstResponder];
    }
}

- (void)resignFirstTextInputResponder
{
    if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleInstanceValue)]) {
        [((INVRuleInstanceActualParamTableViewCell *) self.ruleInstanceCellBeingEdited).ruleInstanceValue resignFirstResponder];
    }
    else if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleName)]) {
        [((INVRuleInstanceNameTableViewCell *) self.ruleInstanceCellBeingEdited).ruleName resignFirstResponder];
    }
    else if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleDescription)]) {
        [((INVRuleInstanceOverviewTableViewCell *) self.ruleInstanceCellBeingEdited).ruleDescription resignFirstResponder];
    }
}

- (void)transformRuleInstanceParamsToArray:(INVRuleInstance *)ruleInstance definition:(INVRule *)ruleDefinition
{
    [self.intermediateRuleInstanceActualParams removeAllObjects];

    NSMutableDictionary *entries = [NSMutableDictionary new];

    [ruleDefinition.formalParams.properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        entries[key] = @"";
    }];

    [ruleInstance.actualParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        entries[key] = obj;
    }];

    [entries enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.intermediateRuleInstanceActualParams addObject:@{INV_ActualParamName : key, INV_ActualParamValue : obj}];
    }];
}

- (void)transformRuleDefinitionParamsToArray:(INVRuleFormalParam *)formalParam
{
    NSDictionary *ruleProperties = formalParam.properties;

    [ruleProperties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *actualParam = @{ INV_ActualParamName : key, INV_ActualParamValue : @"" };
        [self.intermediateRuleInstanceActualParams addObject:actualParam];
    }];
}

- (INVRuleInstanceActualParamDictionary)transformRuleInstanceArrayToRuleInstanceParams:(NSArray *)actualParamsArray
{
    NSMutableDictionary *actualParam = [[NSMutableDictionary alloc] initWithCapacity:0];

    [actualParamsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *actualDict = obj;
        NSString *key = actualDict[INV_ActualParamName];
        NSString *value = actualDict[INV_ActualParamValue];

        [actualParam setObject:value forKey:key];
    }];

    return actualParam;
}

- (void)scrapeTableViewForUpdatedContent
{
    INVRuleInstanceOverviewTableViewCell *overviewCell = (INVRuleInstanceOverviewTableViewCell *)
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_RULEINSTANCEDETAILS_OVERVIEW
                                                                 inSection:SECTION_RULEINSTANCEDETAILS]];
    self.intermediateRuleOverview = overviewCell.ruleDescription.text;

    NSMutableArray *updatedActualParamsArray = [[NSMutableArray alloc] initWithCapacity:0];

    [self.intermediateRuleInstanceActualParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleInstanceActualParamTableViewCell *actualParamCell = (INVRuleInstanceActualParamTableViewCell *)
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:SECTION_RULEINSTANCEACTUALPARAM]];

        NSDictionary *actualParam = @{
            INV_ActualParamName : actualParamCell.ruleInstanceKey.text,
            INV_ActualParamValue : actualParamCell.ruleInstanceValue.text
        };

        [updatedActualParamsArray addObject:actualParam];

    }];
    self.intermediateRuleInstanceActualParams = [NSMutableArray arrayWithArray:updatedActualParamsArray];
}

#pragma mark - accessor
- (NSMutableArray *)intermediateRuleInstanceActualParams
{
    if (!_intermediateRuleInstanceActualParams) {
        _intermediateRuleInstanceActualParams = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _intermediateRuleInstanceActualParams;
}

- (INVGenericTableViewDataSource *)dataSource
{
    // Return the right object depending on whether rule instance is modified or a new rule instance is created
    if (!_dataSource) {
        if (self.ruleInstanceId) {
            INVRuleInstance *ruleInstance =
                [self.globalDataManager.invServerClient.analysesManager ruleInstanceForRuleInstanceId:self.ruleInstanceId
                                                                                        forAnalysisId:self.analysesId];

            self.intermediateRuleOverview = ruleInstance.overview ? ruleInstance.overview : @"";
            self.ruleName = ruleInstance.ruleName;
        }
        else {
            self.intermediateRuleOverview = @"";
        }
        NSArray *ruleInfoArray = @[ self.ruleName, self.intermediateRuleOverview ];
        self.dataSource = [[INVGenericTableViewDataSource alloc] initWithDataArray:ruleInfoArray
                                                                        forSection:SECTION_RULEINSTANCEDETAILS
                                                                      forTableView:self.tableView];
    }
    return _dataSource;
}

- (INVRulesManager *)rulesManager
{
    if (!_rulesManager) {
        _rulesManager = self.globalDataManager.invServerClient.rulesManager;
    }
    return _rulesManager;
}

@end
