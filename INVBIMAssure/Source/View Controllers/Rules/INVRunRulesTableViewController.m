//
//  INVRunRulesTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.

// TODO: All ruleset related logic will go away when we move to rule instances only model. So lot of the (untidy) code will
// become obsolete.

#import "INVRunRulesTableViewController.h"
#import "INVRunRuleSetHeaderView.h"
#import "INVBlockUtils.h"
#import "INVRuleInstanceTableViewController.h"
#import "INVBlockUtils.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 60;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;

@interface INVRunRulesTableViewController () <UITableViewDataSource, UITableViewDelegate, INVRunRuleSetHeaderViewActionDelegate>
@property (nonatomic, strong) INVRulesManager *rulesManager;
@property (nonatomic, strong) INVRuleSetMutableArray ruleSets;
@property (nonatomic, strong) NSMutableSet *selectedRuleInstanceIds;
@property (nonatomic, strong) NSMutableSet *selectedRuleSetIds;
@end

@implementation INVRunRulesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"SELECT_RULES_TO_RUN", nil);
    [self.runRulesButton setEnabled:NO];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;

    self.tableView.allowsSelectionDuringEditing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self fetchRuleSetIdsForFile];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.selectedRuleInstanceIds = nil;
    self.selectedRuleSetIds = nil;
    self.ruleSets = nil;
    self.rulesManager = nil;
}

#pragma mark - Navigation

- (void)onRefreshControlSelected:(UIRefreshControl *)sender
{
    [self.refreshControl endRefreshing];

    [self fetchRuleSetIdsForFile];
}

- (IBAction)manualDismiss:(UIStoryboardSegue *)sender
{
    // NOTE: We don't actually need a manual dismiss in this place.
    [self fetchRuleSetIdsForFile];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ModifyRuleInstanceSegue"]) {
        UITableViewCell *tableViewCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tableViewCell];

        INVRuleSet *ruleSet = self.ruleSets[indexPath.section];
        INVRuleInstance *ruleInstance = ruleSet.ruleInstances[indexPath.row];

        INVRuleInstanceTableViewController *ruleInstanceViewController =
            (INVRuleInstanceTableViewController *) segue.destinationViewController;

        ruleInstanceViewController.projectId = self.projectId;
        ruleInstanceViewController.analysesId = ruleSet.ruleSetId;
        ruleInstanceViewController.ruleInstanceId = ruleInstance.ruleInstanceId;
    }
}

#pragma mark - UITableViewDataSource
#warning See if we can move the data source out into a separate object
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    INVRuleSet *ruleSet = self.ruleSets[section];
    return ruleSet.ruleInstances.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.ruleSets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    INVRuleSet *ruleSet = self.ruleSets[indexPath.section];

    NSArray *ruleInstances = ruleSet.ruleInstances;
    INVRuleInstance *ruleInstance = [ruleInstances objectAtIndex:indexPath.row];

    NSNumber *ruleInstanceId = ruleInstance.ruleInstanceId;
    cell = [tableView dequeueReusableCellWithIdentifier:@"RuleSetCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RuleSetCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView setTintColor:[UIColor darkGrayColor]];
    }

    cell.textLabel.text = ruleInstance.ruleName;
    cell.detailTextLabel.text = ruleInstance.overview;

    if ([ruleInstance.emptyParamCount integerValue] > 0) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self errorImage]];
    }
    else if ([self.selectedRuleInstanceIds containsObject:ruleInstanceId]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self selectedImage]];
    }
    else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self deselectedImage]];
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return DEFAULT_HEADER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVRuleSet *ruleSet = self.ruleSets[indexPath.section];
    INVRuleInstance *ruleInstance = ruleSet.ruleInstances[indexPath.row];

    if ([ruleInstance.emptyParamCount integerValue] > 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UNCONFIGURED_RULE_INSTANCE_TITLE", nil)
                                                message:NSLocalizedString(@"UNCONFIGURED_RULE_INSTANCE_MESSAGE", nil)
                                         preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UNCONFIGURED_RULE_INSTANCE_NAVIGATE", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self.ruleConfigurationTransitionObject perform:cell];
                                                          }]];

        [self presentViewController:alertController animated:YES completion:nil];

        return;
    }

    NSNumber *ruleInstanceId = ruleInstance.ruleInstanceId;

    if ([self.selectedRuleInstanceIds containsObject:ruleInstanceId]) {
        [self.selectedRuleInstanceIds removeObject:ruleInstanceId];
    }
    else {
        [self.selectedRuleInstanceIds addObject:ruleInstanceId];
    }

    NSNumber *ruleSetId = ruleSet.ruleSetId;
    if ([self.selectedRuleSetIds containsObject:ruleSetId]) {
        NSInteger ruleSetIndex = [self indexOfRuleSet:ruleSetId];

        [self.selectedRuleSetIds removeObject:ruleSetId];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ruleSetIndex]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    INVRuleSet *ruleSet = self.ruleSets[section];

    NSArray *objects = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"INVRunRuleSetHeaderView" owner:nil options:nil];
    INVRunRuleSetHeaderView *headerView = [objects firstObject];

    headerView.actionDelegate = self;
    headerView.ruleSetNameLabel.text = ruleSet.name;
    headerView.ruleSetId = ruleSet.ruleSetId;
    if ([self.selectedRuleSetIds containsObject:ruleSet.ruleSetId]) {
        [headerView.runRuleSetToggleButton setSelected:YES];
    }
    else {
        [headerView.runRuleSetToggleButton setSelected:NO];
    }
    return headerView;
}

#pragma mark - server side

- (void)fetchRuleSetIdsForFile
{
    [self showLoadProgress];
    [self.globalDataManager.invServerClient
        getAllRuleSetMembersForPkgMaster:self.fileMasterId
                     WithCompletionBlock:^(INVEmpireMobileError *error) {
                         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

                         if (!error) {
                             [self updateRuleSetsFromServer];
                         }
                         else {
                             UIAlertController *errController = [[UIAlertController alloc]
                                 initWithErrorMessage:NSLocalizedString(@"ERROR_RULESET_LOAD", nil), error.code.integerValue];
                             [self presentViewController:errController animated:YES completion:nil];
                         }
                     }];
}

- (void)runRuleInstances
{
#warning For now ignoring rulesets and only executing on per rule instance basis. Hoping for a better API to combine them
    __block INVEmpireMobileError *ruleExecutionError;

    id successBlock = [INVBlockUtils blockForExecutingBlock:^{
        [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

        if (ruleExecutionError) {
            UIAlertController *errController = [[UIAlertController alloc]
                initWithErrorMessage:NSLocalizedString(@"ERROR_RUN_RULES", nil), ruleExecutionError.code.integerValue];
            [self presentViewController:errController animated:YES completion:nil];
        }
        else {
            [self showSuccessAlertMessage:NSLocalizedString(@"RUN_RULE_SUCCESS", nil)];
        }
    } afterNumberOfCalls:self.selectedRuleInstanceIds.count];

    [self.selectedRuleInstanceIds enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.globalDataManager.invServerClient executeRuleInstance:obj
                                            againstPackageVersionId:self.fileVersionId
                                                withCompletionBlock:^(INVEmpireMobileError *error) {
                                                    if (error) {
                                                        ruleExecutionError = error;
                                                    }

                                                    [successBlock invoke];
                                                }];

    }];
}

#pragma mark - INVRunRuleSetHeaderViewActionDelegate
- (void)onRuleSetToggled:(INVRunRuleSetHeaderView *)sender
{
    NSNumber *tappedRuleSetId = sender.ruleSetId;
    [self updateRuleSetEntryWithId:tappedRuleSetId];
}

- (void)updateRuleSetEntryWithId:(NSNumber *)ruleSetId
{
    NSInteger ruleSetIndex = [self indexOfRuleSet:ruleSetId];
    INVRuleSet *ruleSet = self.ruleSets[ruleSetIndex];

    BOOL ruleSetEnabled = YES;

    if ([self.selectedRuleSetIds containsObject:ruleSetId]) {
        [self.selectedRuleSetIds removeObject:ruleSetId];
        ruleSetEnabled = NO;
    }
    else {
        [self.selectedRuleSetIds addObject:ruleSetId];
    }

    [ruleSet.ruleInstances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleInstance *ruleInstance = obj;
        NSNumber *ruleInstanceId = ruleInstance.ruleInstanceId;

        if ([ruleInstance.emptyParamCount integerValue] > 0) {
            return;
        }

        if (ruleSetEnabled) {
            [self.selectedRuleInstanceIds addObject:ruleInstanceId];
        }
        else {
            [self.selectedRuleInstanceIds removeObject:ruleInstanceId];
        }
    }];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ruleSetIndex]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)indexOfRuleSet:(NSNumber *)ruleSetId
{
    return [self.ruleSets indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj ruleSetId] == ruleSetId;
    }];
}

#pragma mark - accessor
- (NSMutableSet *)selectedRuleInstanceIds
{
    if (!_selectedRuleInstanceIds) {
        _selectedRuleInstanceIds = [[NSMutableSet alloc] initWithCapacity:0];
    }
    return _selectedRuleInstanceIds;
}

- (INVRuleSetMutableArray)ruleSets
{
    if (!_ruleSets) {
        _ruleSets = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _ruleSets;
}

- (NSMutableSet *)selectedRuleSetIds
{
    if (!_selectedRuleSetIds) {
        _selectedRuleSetIds = [[NSMutableSet alloc] initWithCapacity:0];
    }
    return _selectedRuleSetIds;
}

- (UIImage *)errorImage
{
    FAKFontAwesome *errorIcon = [FAKFontAwesome warningIconWithSize:30];
    [errorIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];

    return [errorIcon imageWithSize:CGSizeMake(30, 30)];
}

- (UIImage *)selectedImage
{
    FAKFontAwesome *selectedIcon = [FAKFontAwesome checkCircleIconWithSize:30];
    [selectedIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
    return [selectedIcon imageWithSize:CGSizeMake(30, 30)];
}

- (UIImage *)deselectedImage
{
    FAKFontAwesome *deselectedIcon = [FAKFontAwesome circleOIconWithSize:30];
    [deselectedIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    return [deselectedIcon imageWithSize:CGSizeMake(30, 30)];
}

#pragma mark - helpers
- (void)showSuccessAlertMessage:(NSString *)message
{
    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *successAlertController =
        [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];

    [successAlertController addAction:action];
    [self presentViewController:successAlertController animated:YES completion:nil];
}

- (INVRulesManager *)rulesManager
{
    if (!_rulesManager) {
        _rulesManager = self.globalDataManager.invServerClient.rulesManager;
    }
    return _rulesManager;
}

- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

// Most of this stuff will go away
- (void)updateRuleSetsFromServer
{
    NSSet *rulesetIdsInFile = [self.rulesManager ruleSetIdsForPkgMaster:self.fileMasterId];
    NSInteger numRSIds = rulesetIdsInFile.count;
    id errorBlock = ^(void) {
        UIAlertController *errController =
            [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_RULESET_EMPTY", nil)];
        [self presentViewController:errController animated:YES completion:nil];

    };

    id successBlock = [INVBlockUtils blockForExecutingBlock:^{

        INVRuleSetMutableArray ruleSetsAssociatedWithFile = [[self.rulesManager ruleSetsForIds:rulesetIdsInFile] mutableCopy];
        self.ruleSets = ruleSetsAssociatedWithFile;
        // Display error
        if (!self.ruleSets.count) {
            [errorBlock invoke];
        }
        else {
            [self.runRulesButton setEnabled:YES];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }

    } afterNumberOfCalls:numRSIds];

    [rulesetIdsInFile enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSNumber *ruleSetId = obj;

        [self.globalDataManager.invServerClient getRuleSetForRuleSetId:ruleSetId
                                                   WithCompletionBlock:^(INVEmpireMobileError *error) {
                                                       if (!error) {
                                                           [successBlock invoke];
                                                       }
                                                       else {
                                                           [errorBlock invoke];
                                                       }

                                                   }];
    }];
}
- (void)logRulesToConsole
{
    [self.ruleSets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleSet *ruleSet = obj;
        [ruleSet.ruleInstances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVLogDebug(@"Rule Instance for ruleset $%@ is %@\n", ruleSet.ruleSetId, obj);
        }];
    }];
}

#pragma mark - UIEvent Handlers

- (IBAction)onRunRulesSelected:(UIButton *)sender
{
    [self runRuleInstances];
}
@end
