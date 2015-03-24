//
//  INVRuleInstanceTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewController.h"

#import "INVRuleInstanceElementTypeParamTableViewCell.h"
#import "INVRuleInstanceStringParamTableViewCell.h"
#import "INVRuleInstanceOverviewTableViewCell.h"
#import "INVRuleInstanceNameTableViewCell.h"
#import "INVAnalysisRuleElementTypesTableViewController.h"

#import "NSObject+INVCustomizations.h"
#import "NSArray+INVCustomizations.h"
#import "UIView+INVCustomizations.h"

static const NSInteger SECTION_RULEINSTANCEDETAILS = 0;
static const NSInteger SECTION_RULEINSTANCEACTUALPARAM = 1;
static const NSInteger ROW_RULEINSTANCEDETAILS_NAME = 0;
static const NSInteger ROW_RULEINSTANCEDETAILS_OVERVIEW = 1;

static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_OVERVIEW_CELL_HEIGHT = 175;

@interface INVRuleInstanceTableViewController ()

@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, strong) INVRulesManager *rulesManager;

@property (nonatomic, strong) NSMutableArray *originalRuleInstanceActualParams;
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

    UINib *parameterStringNib = [UINib nibWithNibName:NSStringFromClass([INVRuleInstanceStringParamTableViewCell class])
                                               bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:parameterStringNib forCellReuseIdentifier:@"RuleInstanceStringCell"];

    UINib *parameterElementTypeNib =
        [UINib nibWithNibName:NSStringFromClass([INVRuleInstanceElementTypeParamTableViewCell class])
                       bundle:[NSBundle bundleForClass:[self class]]];

    [self.tableView registerNib:parameterElementTypeNib forCellReuseIdentifier:@"RuleInstanceElementTypeCell"];

    UINib *rioNib =
        [UINib nibWithNibName:@"INVRuleInstanceOverviewTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:rioNib forCellReuseIdentifier:@"RuleInstanceOverviewTVC"];

    UINib *rinNib = [UINib nibWithNibName:@"INVRuleInstanceNameTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:rinNib forCellReuseIdentifier:@"RuleInstanceNameTVC"];

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

    [self setupTableViewDataSource];

    if (self.ruleInstanceId) {
        [self fetchRuleInstance];
    }
    else if (self.ruleId) {
        [self fetchRuleDefinition];
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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentSelection"]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(uintptr_t) context inSection:SECTION_RULEINSTANCEACTUALPARAM];
        INVRuleInstanceElementTypeParamTableViewCell *elementTypeCell = (id) [self.tableView cellForRowAtIndexPath:indexPath];

        elementTypeCell.actualParamDictionary[INVActualParamValue] = change[NSKeyValueChangeNewKey];

        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
    }
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
            cell.overview = overview;
        };
    [self.dataSource registerCellWithIdentifier:@"RuleInstanceOverviewTVC"
                                 configureBlock:cellConfigurationBlockForRuleOverview
                                   forIndexPath:indexPathForRuleOverview];
}

- (void)setupRuleInstanceActualParamsDataSource
{
    [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams forSection:SECTION_RULEINSTANCEACTUALPARAM];
    [self.dataSource registerCellBlock:^UITableViewCell *(id cellData, NSIndexPath *indexPath) {
        id cell = nil;
        INVParameterType type = [cellData[INVActualParamType] integerValue];
        switch (type) {
            case INVParameterTypeString:
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"RuleInstanceStringCell" forIndexPath:indexPath];
                break;

            case INVParameterTypeElementType:
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"RuleInstanceElementTypeCell" forIndexPath:indexPath];
                break;

            case INVParameterTypeNumber:
                [NSException raise:NSInvalidArgumentException format:@"Numbers not currently supported"];
                break;
        }

        [cell setActualParamDictionary:cellData];
        return cell;
    } forSection:SECTION_RULEINSTANCEACTUALPARAM];
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
                       INV_ALWAYS:
                           [self.hud hide:YES];

                       INV_SUCCESS:
                           [self transformRuleInstanceParamsToArray:ruleInstance definition:rule];
                           [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams
                                                     forSection:SECTION_RULEINSTANCEACTUALPARAM];

                           [self.tableView reloadData];

                       INV_ERROR:
                           INVLogError(@"%@", error);

                           UIAlertController *errController = [[UIAlertController alloc]
                               initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_DEFINITION_FORINSTANCE_LOAD", nil),
                               error.code.integerValue];
                           [self presentViewController:errController animated:YES completion:nil];
                   }];
    }

    [self.tableView reloadData];
}

- (void)fetchRuleDefinition
{
    [self showLoadProgress];
    [self.globalDataManager.invServerClient
        getRuleDefinitionForRuleId:self.ruleId
               WithCompletionBlock:^(INVRule *rule, INVEmpireMobileError *error) {
                   INV_ALWAYS:
                       [self.hud hide:YES];

                   INV_SUCCESS:
                       self.ruleDefinition =
                           [self.globalDataManager.invServerClient.rulesManager ruleDefinitionForRuleId:self.ruleId];

                       [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams
                                                 forSection:SECTION_RULEINSTANCEACTUALPARAM];

                       [self.tableView reloadData];

                   INV_ERROR:
                       INVLogError(@"%@", error);

                       UIAlertController *errController = [[UIAlertController alloc]
                           initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_DEFINITION_FORINSTANCE_LOAD", nil),
                           error.code.integerValue];
                       [self presentViewController:errController animated:YES completion:nil];

               }];
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
                      INV_ALWAYS:
                      INV_SUCCESS:
                          [self showSuccessAlertMessage:NSLocalizedString(@"RULE_INSTANCE_CREATED_SUCCESS", nil) isCreated:YES];

                      INV_ERROR:
                          INVLogError(@"%@", error);

                          UIAlertController *errController = [[UIAlertController alloc]
                              initWithErrorMessage:NSLocalizedString(@"ERROR_RULEINSTANCE_CREATE", nil),
                              error.code.integerValue];
                          [self presentViewController:errController animated:YES completion:nil];
                  }];
}

- (void)sendUpdatedRuleInstanceToServer
{
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
                            INV_ALWAYS:
                            INV_SUCCESS:
                                [self showSuccessAlertMessage:NSLocalizedString(@"RULE_INSTANCE_UPDATED_SUCCESS", nil)
                                                    isCreated:NO];
                            INV_ERROR:
                                INVLogError(@"%@", error);

                                UIAlertController *errController = [[UIAlertController alloc]
                                    initWithErrorMessage:NSLocalizedString(@"ERROR_RULEINSTANCE_UPDATE", nil),
                                    error.code.integerValue];
                                [self presentViewController:errController animated:YES completion:nil];
                        }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CancelSegue"]) {
        [self resignFirstTextInputResponder];
    }

    if ([segue.identifier isEqualToString:@"showAnalysisRuleElements"]) {
        INVRuleInstanceElementTypeParamTableViewCell *cell =
            [sender findSuperviewOfClass:[INVRuleInstanceElementTypeParamTableViewCell class] predicate:nil];

        INVAnalysisRuleElementTypesTableViewController *ruleTypesVC = segue.destinationViewController;

        ruleTypesVC.projectId = self.projectId;
        ruleTypesVC.analysisId = self.analysesId;
        ruleTypesVC.currentSelection = cell.actualParamDictionary[INVActualParamValue];

        [ruleTypesVC addObserver:self
                      forKeyPath:@"currentSelection"
                         options:NSKeyValueObservingOptionNew
                         context:(void *) (uintptr_t) [self.tableView indexPathForCell:cell].row];

        __weak id weakSelf = self;
        [ruleTypesVC addDeallocHandler:^(id ruleTypesVC) {
            [ruleTypesVC removeObserver:weakSelf forKeyPath:@"currentSelection"];
        }];

        ruleTypesVC.popoverPresentationController.sourceView = sender;
        ruleTypesVC.popoverPresentationController.sourceRect = [sender bounds];
    }
}

- (IBAction)done:(UIStoryboardSegue *)sender
{
}

#pragma mark - UIEventHandler

- (IBAction)onSaveRuleInstanceTapped:(UIBarButtonItem *)sender
{
    if (sender == self.saveBarButton) {
        [self resignFirstTextInputResponder];
        [self scrapeTableViewForUpdatedContent];

        if (self.ruleInstanceId) {
            [self sendUpdatedRuleInstanceToServer];
        }
        else {
            [self sendCreateRuleInstanceRequestToServer];
        }
    }
}

- (IBAction)onRuleInstanceShowElementTypeDropdown:(id)sender
{
    [self performSegueWithIdentifier:@"showAnalysisRuleElements" sender:sender];
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
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.ruleInstanceCellBeingEdited = cell;

    [cell becomeFirstResponder];
}

- (void)resignFirstTextInputResponder
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)transformRuleInstanceParamsToArray:(INVRuleInstance *)ruleInstance definition:(INVRule *)ruleDefinition
{
    NSArray *keys = ruleDefinition.formalParams.properties.allKeys;
    NSDictionary *entries = [NSDictionary dictionaryWithObjects:[keys arrayByApplyingBlock:^id(id key, NSUInteger _, BOOL *__) {
        INVParameterType type = INVParameterTypeFromString(ruleDefinition.formalParams.properties[key][@"type"]);
        if ([key isEqual:@"name"]) {
            type = INVParameterTypeElementType;
        }

        return [@{ INVActualParamName : key, INVActualParamType : @(type) } mutableCopy];
    }] forKeys:keys];

    [ruleInstance.actualParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        entries[key][INVActualParamValue] = obj;
    }];

    [self.intermediateRuleInstanceActualParams setArray:entries.allValues];
    self.originalRuleInstanceActualParams =
        [[NSMutableArray alloc] initWithArray:self.intermediateRuleInstanceActualParams copyItems:YES];
}

- (INVRuleInstanceActualParamDictionary)transformRuleInstanceArrayToRuleInstanceParams:(NSArray *)actualParamsArray
{
    NSMutableDictionary *actualParam = [[NSMutableDictionary alloc] initWithCapacity:0];

    [actualParamsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *actualDict = obj;
        NSString *key = actualDict[INVActualParamName];
        NSString *value = actualDict[INVActualParamValue] ?: @"";

        [actualParam setObject:value forKey:key];
    }];

    return actualParam;
}

- (void)scrapeTableViewForUpdatedContent
{
    INVRuleInstanceOverviewTableViewCell *overviewCell = (INVRuleInstanceOverviewTableViewCell *)
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_RULEINSTANCEDETAILS_OVERVIEW
                                                                 inSection:SECTION_RULEINSTANCEDETAILS]];

    self.intermediateRuleOverview = overviewCell.overview;
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
