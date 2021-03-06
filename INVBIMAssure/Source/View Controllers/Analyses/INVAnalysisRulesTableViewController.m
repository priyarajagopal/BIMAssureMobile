//
//  INVAnalysisRulesTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/18/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisRulesTableViewController.h"
#import "INVRuleDefinitionsTableViewController.h"
#import "INVRuleInstanceTableViewCell.h"
#import "INVRuleDefinitionSelectionTableViewController.h"
#import "UIView+INVCustomizations.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 130;

@interface INVAnalysisRulesTableViewController () <INVRuleInstanceTableViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, copy) INVAnalysis *analysis;
@property (nonatomic,strong) IBOutlet INVTransitionToStoryboard *editRuleInstanceTransition;
@property (nonatomic,strong) IBOutlet INVTransitionToStoryboard *selectRuleDefinitionTransition;
@property (nonatomic, strong)  UIPickerView *ruleTypePickerView;

- (IBAction)onRuleInstanceEditSelected:(id)sender;
- (IBAction)onRuleInstanceAddSelected:(id)sender;
- (IBAction)onRuleInstanceDeleteSelected:(id)sender;

@end

@implementation INVAnalysisRulesTableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *ruleInstanceNib = [UINib nibWithNibName:@"INVRuleInstanceTableViewCell" bundle:nil];
    [self.tableView registerNib:ruleInstanceNib forCellReuseIdentifier:@"ruleInstanceCell"];

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self fetchListOfRules];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRuleDefinitions"]) {

        INVRuleDefinitionsTableViewController *ruleDefinitionsVC = (INVRuleDefinitionsTableViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
        ruleDefinitionsVC.analysisId = self.analysisId;

    }
    
    if ([[segue identifier] isEqualToString:@"RuleDefinitionSelectionSegue"]) {
        INVRuleDefinitionSelectionTableViewController *ruleDefinitionsSelectVC = (INVRuleDefinitionSelectionTableViewController*)(segue.destinationViewController);
        ruleDefinitionsSelectVC.analysisId = self.analysisId;
    }

    if ([[segue identifier] isEqualToString:@"editRuleInstance"]) {
        INVRuleInstanceTableViewController *ruleInstanceVC = [segue destinationViewController];
        ruleInstanceVC.delegate = self;
        ruleInstanceVC.ruleName = [sender ruleName];
        ruleInstanceVC.ruleInstanceId = [sender ruleInstanceId];
        ruleInstanceVC.ruleId = [sender ruleDefId];
        ruleInstanceVC.projectId = self.projectId;
        ruleInstanceVC.analysesId = self.analysisId;
    }
}

#pragma mark - Content Management

- (void)fetchListOfRules
{
    id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.globalDataManager.invServerClient
           getAnalysesForId:self.analysisId
        withCompletionBlock:^(id result, INVEmpireMobileError *error) {
            INV_ALWAYS:
                [self.refreshControl endRefreshing];
                [hud hide:YES];

            INV_SUCCESS:
                self.analysis = result;
                [self reloadTable];

            INV_ERROR:
                INVLogError(@"%@", error);

                UIAlertController *alertController =
                    [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSIS_RULES_FETCH", nil)];
                [self presentViewController:alertController animated:YES completion:nil];
        }];
}

- (void)deleteRule:(INVRuleInstance *)rule
{
    UIAlertController *confirmDeleteController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"DELETE_RULE_CONFIRM_TITLE", nil)
                                            message:NSLocalizedString(@"DELETE_RULE_CONFIRM_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [confirmDeleteController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"DELETE_RULE_CONFIRM_NEGATIVE", nil)
                                                                style:UIAlertActionStyleCancel
                                                              handler:nil]];

    [confirmDeleteController
        addAction:[UIAlertAction
                      actionWithTitle:NSLocalizedString(@"DELETE_RULE_CONFIRM_POSITIVE", nil)
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction *action) {
                                  id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

                                  [self.globalDataManager.invServerClient
                                      deleteRuleInstanceForId:rule.ruleInstanceId
                                          WithCompletionBlock:^(INVEmpireMobileError *error) {
                                              INV_ALWAYS:
                                                  [hud hide:YES];

                                              INV_SUCCESS:
                                                  [self reloadAnalysisFromCache];
                                                  [self reloadTable];

                                              INV_ERROR:
                                                  INVLogError(@"%@", error);

                                                  UIAlertController *errorController = [[UIAlertController alloc]
                                                      initWithErrorMessage:@"ERROR_RULE_INSTANCE_DELETE"];

                                                  [self presentViewController:errorController animated:YES completion:nil];
                                          }];
                              }]];

    [self presentViewController:confirmDeleteController animated:YES completion:nil];
}

#pragma mark - IBActions

- (void)onRefreshControlSelected:(id)sender
{
    [self fetchListOfRules];
}

- (void)onRuleInstanceEditSelected:(id)sender
{
    INVRuleInstanceTableViewCell *cell = [sender findSuperviewOfClass:[INVRuleInstanceTableViewCell class] predicate:nil];

    [self.editRuleInstanceTransition perform:cell.ruleInstance];
}

- (void)onRuleInstanceDeleteSelected:(id)sender
{
    INVRuleInstanceTableViewCell *cell = [sender findSuperviewOfClass:[INVRuleInstanceTableViewCell class] predicate:nil];

    [self deleteRule:cell.ruleInstance];
}

- (void)onRuleInstanceAddSelected:(id)sender
{
      [self.selectRuleDefinitionTransition perform:sender];
}

- (IBAction)manualDismissForAnalysisRulesTVC:(UIStoryboardSegue *)segue
{
    [self fetchListOfRules];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.analysis.rules count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVRuleInstanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ruleInstanceCell"];
    INVRuleInstance *rule = self.analysis.rules[indexPath.row];

    cell.ruleInstance = rule;

    return cell;
}

#pragma mark - INVRuleInstanceTableViewControllerDelegate

- (void)onRuleInstanceCreated:(INVRuleInstanceTableViewController *)sender
{
}

- (void)onRuleInstanceModified:(INVRuleInstanceTableViewController *)sender
{
    [self reloadAnalysisFromCache];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}


#pragma mark- UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 1) {
        return NSLocalizedString(@"Pick from Rule Definitions", nil);
    }
    else {
        return  NSLocalizedString(@"Pick from Analysis Templates", nil);
    }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    INVLogDebug();
}




#pragma mark - helpers

- (void)reloadTable
{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)reloadAnalysisFromCache
{
    self.analysis = [[self.globalDataManager.invServerClient.analysesManager analysesForIds:@[ self.analysisId ]] firstObject];
}

@end
