//
//  INVRuleInstanceTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewController.h"

#import "INVRuleInstanceRangeTypeParamTableViewCell.h"
#import "INVRuleInstanceArrayParamTableViewCell.h"
#import "INVRuleInstanceBATypeParamTableViewCell.h"
#import "INVRuleInstanceGeneralTypeParamTableViewCell.h"

#import "INVRuleInstanceOverviewTableViewCell.h"
#import "INVTextFieldTableViewCell.h"
#import "INVBAElementTypesTableViewController.h"
#import "INVUnitsListTableViewController.h"

#import "NSObject+INVCustomizations.h"
#import "NSArray+INVCustomizations.h"
#import "UIView+INVCustomizations.h"

#import "INVRuleParameterParser.h"

static const NSInteger SECTION_RULEINSTANCEDETAILS = 0;
static const NSInteger SECTION_RULEINSTANCEACTUALPARAM = 1;
static const NSInteger ROW_RULEINSTANCEDETAILS_NAME = 0;
static const NSInteger ROW_RULEINSTANCEDETAILS_OVERVIEW = 1;

static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_OVERVIEW_CELL_HEIGHT = 175;

@interface INVRuleInstanceTableViewController ()

@property (nonatomic, strong) NSMutableDictionary *sizingCells;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, strong) NSMutableArray *originalRuleInstanceActualParams;
@property (nonatomic, strong) NSMutableArray *intermediateRuleInstanceActualParams; // Array of INV_ActualParamKeyValuePair
                                                                                    // objects transformed from the array params
                                                                                    // dictionary fetched from server
@property (nonatomic, strong) NSString *intermediateRuleOverview;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveBarButton;
@property (nonatomic, weak) UITableViewCell *ruleInstanceCellBeingEdited;

@end

@implementation INVRuleInstanceTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"GIVE NAME OF RULE INSTANCE HERE", nil);

    self.sizingCells = [NSMutableDictionary new];

    [self registerClass:[INVRuleInstanceGeneralTypeParamTableViewCell class] forCellReuseIdentifier:@"RuleInstanceGenericCell"];
    [self registerClass:[INVRuleInstanceBATypeParamTableViewCell class] forCellReuseIdentifier:@"RuleInstanceBATypeCell"];
    [self registerClass:[INVRuleInstanceArrayParamTableViewCell class] forCellReuseIdentifier:@"RuleInstanceArrayCell"];
    [self registerClass:[INVRuleInstanceRangeTypeParamTableViewCell class] forCellReuseIdentifier:@"RuleInstanceRangeCell"];

    UINib *rioNib =
        [UINib nibWithNibName:@"INVRuleInstanceOverviewTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:rioNib forCellReuseIdentifier:@"RuleInstanceOverviewTVC"];

    UINib *rinNib = [UINib nibWithNibName:@"INVTextFieldTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
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

    if (self.ruleId) {
        [self fetchRuleDefinition];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.intermediateRuleInstanceActualParams = nil;
    self.saveBarButton = nil;
    self.tableView.dataSource = nil;
    self.dataSource = nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (([keyPath isEqualToString:@"currentSelection"]) && ![change[NSKeyValueChangeNewKey] isKindOfClass:[NSNull class]]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(uintptr_t) context inSection:SECTION_RULEINSTANCEACTUALPARAM];
        id cell = (id) [self.tableView cellForRowAtIndexPath:indexPath];

        [cell actualParamDictionary][INVActualParamValue] = change[NSKeyValueChangeNewKey];

        [self.tableView reloadData];
    }

    if ([keyPath isEqualToString:@"currentUnit"]) {
        // if the current unit is nil, the user cancelled.
        // If its NSNull, the user cleared their selection.
        if ([object valueForKeyPath:keyPath] == nil)
            return;

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(uintptr_t) context inSection:SECTION_RULEINSTANCEACTUALPARAM];
        id cell = (id) [self.tableView cellForRowAtIndexPath:indexPath];

        [cell actualParamDictionary][INVActualParamUnit] = change[NSKeyValueChangeNewKey];

        [self.tableView reloadData];
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
        ^(INVTextFieldTableViewCell *cell, NSString *ruleName, NSIndexPath *indexPath) {
            cell.detail.text = ruleName;
            [cell.detail setUserInteractionEnabled:NO];
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

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    id cellData = [self.dataSource objectAtIndexPath:indexPath];
    NSArray *types = cellData[INVActualParamType];
    NSString *cellName;

    if (types.count == 1) {
        if ([[types firstObject] isKindOfClass:[NSNumber class]]) {
            INVParameterType type = [[types firstObject] integerValue];

            switch (type) {
                case INVParameterTypeString:
                case INVParameterTypeNumber:
                case INVParameterTypeDate:
                    cellName = @"Generic";
                    break;

                case INVParameterTypeElementType:
                    cellName = @"BAType";
                    break;

                case INVParameterTypeRange:
                    cellName = @"Range";
                    break;
            }
        }
        else if ([[types firstObject] isKindOfClass:[NSArray class]]) {
            cellName = @"Array";
        }
    }
    else {
        cellName = @"Generic";
    }

    cellName = [NSString stringWithFormat:@"RuleInstance%@Cell", cellName];

    return cellName;
}

- (void)setupRuleInstanceActualParamsDataSource
{
    [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams forSection:SECTION_RULEINSTANCEACTUALPARAM];
    [self.dataSource registerCellBlock:^UITableViewCell *(id cellData, NSIndexPath *indexPath) {
        NSString *cellName = [self cellIdentifierForIndexPath:indexPath];
        id cell = [self.tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];

        [cell setTintColor:[UIColor darkGrayColor]];
        [cell setActualParamDictionary:cellData];

        return cell;
    } forSection:SECTION_RULEINSTANCEACTUALPARAM];
}

#pragma mark - server side
- (void)fetchRuleDefinition
{
    if (!self.analysesId || !self.ruleInstanceId) {
        INVLogError(
            @"Cannot fetch rule instance details for analyses %@ and RuleInstanceId %@", self.analysesId, self.ruleInstanceId);
    }
    else {
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
                           self.intermediateRuleInstanceActualParams =
                               [[[INVRuleParameterParser instance] transformRuleInstanceParamsToArray:ruleInstance
                                                                                           definition:rule] mutableCopy];

                           self.originalRuleInstanceActualParams =
                               [[NSMutableArray alloc] initWithArray:self.intermediateRuleInstanceActualParams copyItems:YES];

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

- (void)sendCreateRuleInstanceRequestToServer
{
    INVRuleInstanceActualParamDictionary actualParam = [[INVRuleParameterParser instance]
        transformRuleInstanceArrayToRuleInstanceParams:self.intermediateRuleInstanceActualParams];

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
    INVRuleInstanceActualParamDictionary actualParam = [[INVRuleParameterParser instance]
        transformRuleInstanceArrayToRuleInstanceParams:self.intermediateRuleInstanceActualParams];

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
        id cell = [sender findSuperviewOfClass:[UITableViewCell class] predicate:nil];

        INVBAElementTypesTableViewController *ruleTypesVC = (id)[segue.destinationViewController topViewController];
        ruleTypesVC.currentSelection = [cell actualParamDictionary][INVActualParamValue];

        [ruleTypesVC addObserver:self
                      forKeyPath:@"currentSelection"
                         options:NSKeyValueObservingOptionNew
                         context:(void *) (uintptr_t) [self.tableView indexPathForCell:cell].row];

        __weak id weakSelf = self;
        [ruleTypesVC addDeallocHandler:^(id ruleTypesVC) {
            [ruleTypesVC removeObserver:weakSelf forKeyPath:@"currentSelection"];
        }];
    }

    if ([segue.identifier isEqualToString:@"showAnalysisRuleUnits"]) {
        id cell = [sender findSuperviewOfClass:[UITableViewCell class] predicate:nil];

        INVUnitsListTableViewController *unitsListVC = (id)[segue.destinationViewController topViewController];
        unitsListVC.currentUnit = [cell actualParamDictionary][INVActualParamUnit];

        [unitsListVC addObserver:self
                      forKeyPath:@"currentUnit"
                         options:NSKeyValueObservingOptionNew
                         context:(void *) (uintptr_t) [self.tableView indexPathForCell:cell].row];

        __weak id weakSelf = self;
        [unitsListVC addDeallocHandler:^(id unitsListVC) {
            [unitsListVC removeObserver:weakSelf forKeyPath:@"currentUnit"];
        }];
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

- (IBAction)onRuleInstanceShowUnitsDropdown:(id)sender
{
    [self performSegueWithIdentifier:@"showAnalysisRuleUnits" sender:sender];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_RULEINSTANCEDETAILS && indexPath.row == 1) {
        return DEFAULT_OVERVIEW_CELL_HEIGHT;
    }

    if (indexPath.section == SECTION_RULEINSTANCEACTUALPARAM) {
        id cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
        id cellData = [self.dataSource objectAtIndexPath:indexPath];

        id sizingCell = self.sizingCells[cellIdentifier];
        [sizingCell setActualParamDictionary:cellData];

        [sizingCell setNeedsUpdateConstraints];
        [sizingCell layoutIfNeeded];

        CGFloat height = [sizingCell systemLayoutSizeFittingSize:CGSizeMake(self.tableView.bounds.size.width, 0)
                                   withHorizontalFittingPriority:UILayoutPriorityRequired
                                         verticalFittingPriority:UILayoutPriorityDefaultLow].height;

        return height;
    }

    return DEFAULT_CELL_HEIGHT;
}

#pragma mark - helper

- (void)registerClass:(Class)kls forCellReuseIdentifier:(NSString *)identifier
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(kls) bundle:[NSBundle bundleForClass:kls]];
    self.sizingCells[identifier] = [[nib instantiateWithOwner:nil options:nil] firstObject];

    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
}

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

- (void)scrapeTableViewForUpdatedContent
{
    INVRuleInstanceOverviewTableViewCell *overviewCell = (INVRuleInstanceOverviewTableViewCell *)
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_RULEINSTANCEDETAILS_OVERVIEW
                                                                 inSection:SECTION_RULEINSTANCEDETAILS]];

    self.intermediateRuleOverview = overviewCell.overview;
}

- (BOOL)validateActualParamsValues:(NSArray *)actualParamArray
{
    for (NSDictionary *actualParam in actualParamArray) {
        id value = actualParam[INVActualParamValue];
        id types = actualParam[INVActualParamType];
        id constraints = actualParam[INVActualParamTypeConstraints];

        NSError* err = [[INVRuleParameterParser instance] isValueValid:value forAnyTypeInArray:types withConstraints:constraints];
        if (err) {
            return NO;
        }
    }

    return YES;
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

@end
