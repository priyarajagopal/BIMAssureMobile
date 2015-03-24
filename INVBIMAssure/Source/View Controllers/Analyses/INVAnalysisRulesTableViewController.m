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

#import "UIView+INVCustomizations.h"

@interface INVAnalysisRulesTableViewController () <INVRuleInstanceTableViewControllerDelegate>

@property (nonatomic) INVAnalysis *analysis;
@property (nonatomic) IBOutlet INVTransitionToStoryboard *editRuleInstanceTransition;

- (IBAction)onRuleInstanceEditSelected:(id)sender;
- (IBAction)onRuleInstanceDeleteSelected:(id)sender;

@end

@implementation INVAnalysisRulesTableViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *ruleInstanceNib = [UINib nibWithNibName:@"INVRuleInstanceTableViewCell" bundle:nil];
    [self.tableView registerNib:ruleInstanceNib forCellReuseIdentifier:@"ruleInstanceCell"];

    [self fetchListOfRules];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRuleDefinitions"]) {
        INVRuleDefinitionsTableViewController *ruleDefinitionsVC = [segue destinationViewController];
        ruleDefinitionsVC.analysisId = self.analysisId;
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
        getAllAnalysesForProject:self.projectId
             withCompletionBlock:^(INVEmpireMobileError *error) {
                 INV_ALWAYS:
                     [self.refreshControl endRefreshing];
                     [hud hide:YES];

                 INV_SUCCESS:
                     self.analysis = nil;
                     [self.tableView reloadData];

                 INV_ERROR:
                     INVLogError(@"%@", error);

                     UIAlertController *alertController =
                         [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSIS_RULES_FETCH", nil)];
                     [self presentViewController:alertController animated:YES completion:nil];
             }];
}

- (INVAnalysis *)analysis
{
    if (_analysis) {
        return _analysis;
    }

    NSFetchRequest *fetchRequest = [self.globalDataManager.invServerClient.analysesManager fetchRequestForAnalyses];
    fetchRequest.predicate =
        [NSPredicate predicateWithFormat:@"projectId = %@ AND analysisId = %@", self.projectId, self.analysisId];

    NSArray *analyses =
        [self.globalDataManager.invServerClient.analysesManager.managedObjectContext executeFetchRequest:fetchRequest
                                                                                                   error:NULL];

    _analysis = [analyses firstObject];

    return _analysis;
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
                                                  [self fetchListOfRules];

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

- (void)manualDismiss:(UIStoryboardSegue *)segue
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

#pragma mark - UITableViewDelegate

#pragma mark - INVRuleInstanceTableViewControllerDelegate

- (void)onRuleInstanceCreated:(INVRuleInstanceTableViewController *)sender
{
}

- (void)onRuleInstanceModified:(INVRuleInstanceTableViewController *)sender
{
    [self fetchListOfRules];

    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

@end
