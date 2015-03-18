//
//  INVRulesListViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRulesListViewController.h"
#import "INVRuleInstanceTableViewCell.h"
#import "INVRulesTableViewDataSource.h"
#import "INVRuleInstanceTableViewController.h"
#import "INVRuleSetTableViewHeaderView.h"
#import "INVRuleSetManageFilesContainerViewController.h"
#import "INVRuleDefinitionsTableViewController.h"
#import "INVProjectListSplitViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;

@interface INVRulesListViewController () <INVRuleSetTableViewHeaderViewAcionDelegate,
    INVRuleInstanceTableViewControllerDelegate, NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate>
@property (nonatomic, strong) INVRulesManager *rulesManager;
@property (nonatomic, strong) NSFetchedResultsController *dataResultsController;
@property (nonatomic, strong) INVRulesTableViewDataSource *dataSource;
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;
@property (nonatomic, strong) NSNumber *selectedRuleInstanceId;
@property (nonatomic, strong) NSNumber *selectedRuleSetId;
@property (nonatomic, strong) INVRuleInstanceTableViewCell *selectedRowInstanceCell;
@end

@implementation INVRulesListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"RULES", nil);

    UINib *nib = [UINib nibWithNibName:@"INVRuleInstanceTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"RuleInstanceCell"];

    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    self.cellsCurrentlyEditing = [[NSMutableSet alloc] initWithCapacity:0];
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

    INVProjectListSplitViewController *splitVC = (INVProjectListSplitViewController *) self.splitViewController;
    [splitVC.aggregateDelegate addDelegate:self];
    [self configureDisplayModeButton];

    self.tableView.dataSource = self.dataSource;
    [self fetchRuleSets];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.rulesManager = nil;
    self.tableView.dataSource = nil;
    self.dataSource = nil;
    self.dataResultsController = nil;
    self.cellsCurrentlyEditing = nil;
    self.selectedRowInstanceCell = nil;
}

#pragma mark - server side
- (void)fetchRuleSets
{
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }

    INVLogDebug();
    [self.globalDataManager.invServerClient
        getAllRuleSetsForProject:self.projectId
             WithCompletionBlock:^(INVEmpireMobileError *error) {
                 if ([self.refreshControl isRefreshing]) {
                     [self.refreshControl endRefreshing];
                 }
                 else {
                     [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
                 }

                 if (!error) {
                     //       [self logRulesToConsole];
                     [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                 }
                 else {
                     UIAlertController *errController = [[UIAlertController alloc]
                         initWithErrorMessage:NSLocalizedString(@"ERROR_RULESET_LOAD", nil), error.code];
                     [self presentViewController:errController animated:YES completion:nil];
                 }
             }];
}

- (void)deleteSelectedRuleInstance
{
    [self.globalDataManager.invServerClient
        deleteRuleInstanceForId:self.selectedRuleInstanceId
            WithCompletionBlock:^(INVEmpireMobileError *error) {
                [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

                if (!error) {
                    //     [self logRulesToConsole];
                    [self removeSelectedRowFromTableView];
                }
                else {
                    UIAlertController *errController = [[UIAlertController alloc]
                        initWithErrorMessage:NSLocalizedString(@"ERROR_RULEINSTANCE_DELETE", nil), error.code.integerValue];
                    [self presentViewController:errController animated:YES completion:nil];
                }
            }];
}

#pragma mark - INVRuleInstanceTableViewActionDelegate
- (void)onViewRuleTappedFor:(INVRuleInstanceTableViewCell *)sender
{
    INVRuleInstanceTableViewCell *ruleInstanceCell = (INVRuleInstanceTableViewCell *) sender;
    // self.selectedRuleInstanceId = ruleInstanceCell.ruleInstanceId;
    // self.selectedRuleSetId = ruleInstanceCell.ruleSetId;
    self.selectedRowInstanceCell = ruleInstanceCell;

    [self performSegueWithIdentifier:@"RuleInstanceViewSegue" sender:self];
}

- (void)onDeleteRuleTappedFor:(INVRuleInstanceTableViewCell *)sender
{
    INVRuleInstanceTableViewCell *ruleInstanceCell = (INVRuleInstanceTableViewCell *) sender;
    // self.selectedRuleInstanceId = ruleInstanceCell.ruleInstanceId;
    // self.selectedRuleSetId = ruleInstanceCell.ruleSetId;
    self.selectedRowInstanceCell = ruleInstanceCell;

    [self showDeletePromptAlert];
}

- (void)showDeletePromptAlert
{
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];

    UIAlertAction *proceedAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"DELETE", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *action) {
                                                              // TODO: Delete from server.
                                                              [self deleteSelectedRuleInstance];
                                                          }];

    UIAlertController *deletePromptAlertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ARE_YOU_SURE", nil)
                                            message:NSLocalizedString(@"DELETE_THE_SELECTED_RULE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [deletePromptAlertController addAction:cancelAction];
    [deletePromptAlertController addAction:proceedAction];

    [self presentViewController:deletePromptAlertController animated:YES completion:nil];
}

- (void)removeSelectedRowFromTableView
{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    /*
    NSIndexPath *indexPathOfCellToDelete = [self.tableView indexPathForSelectedRow];
    [self.tableView deleteRowsAtIndexPaths:@[indexPathOfCellToDelete] withRowAnimation:UITableViewRowAnimationAutomatic];
     */
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#warning use resuable tableheaderfotter view

    INVRuleSet *ruleSet = self.dataResultsController.fetchedObjects[section];

    NSArray *objects =
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"INVRuleSetTableViewHeaderView" owner:nil options:nil];
    INVRuleSetTableViewHeaderView *headerView = [objects firstObject];

    headerView.actionDelegate = self;
    headerView.ruleSetNameLabel.text = ruleSet.name;
    headerView.ruleSetId = ruleSet.ruleSetId;

    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVRuleInstanceTableViewCell *cell = (INVRuleInstanceTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    // [cell openCell];
}

#pragma mark - INVRuleSetTableViewHeaderViewAcionDelegate
- (void)onManageFilesTapped:(INVRuleSetTableViewHeaderView *)sender
{
    INVRuleSetTableViewHeaderView *headerView = (INVRuleSetTableViewHeaderView *) sender;
    self.selectedRuleSetId = headerView.ruleSetId;
    [self performSegueWithIdentifier:@"RuleSetFilesSegue" sender:self];
}

- (void)onAddRuleInstanceTapped:(INVRuleSetTableViewHeaderView *)sender
{
    INVRuleSetTableViewHeaderView *headerView = (INVRuleSetTableViewHeaderView *) sender;
    self.selectedRuleSetId = headerView.ruleSetId;
    [self performSegueWithIdentifier:@"AddRuleInstanceSegue" sender:self];
}

#pragma mark - UIEVent handlers
- (IBAction)manualDismiss:(UIStoryboardSegue *)segue
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRefreshControlSelected:(id)event
{
    [self fetchRuleSets];
}

#pragma mark - INVRuleInstanceTableViewControllerDelegate
- (void)onRuleInstanceModified:(INVRuleInstanceTableViewController *)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                                                  withObject:nil
                                                               waitUntilDone:NO];

                             }];
}

- (void)onRuleInstanceCreated:(INVRuleInstanceTableViewController *)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self performSelectorOnMainThread:@selector(refreshTablePostRuleInstanceCreation)
                                                        withObject:nil
                                                     waitUntilDone:NO];

                             }];
}

- (void)refreshTablePostRuleInstanceCreation
{
    [self fetchRuleSets];
}

- (void)refreshSelectedRows
{
    INVLogDebug(@"numObjects %@", self.dataResultsController.fetchedObjects);

    NSIndexPath *indexPathOfSelectedRow = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadRowsAtIndexPaths:@[ indexPathOfSelectedRow ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type
{
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RuleInstanceViewSegue"]) {
        INVRuleInstanceTableViewController *ruleInstanceTVC = segue.destinationViewController;
        ruleInstanceTVC.ruleInstanceId = self.selectedRuleInstanceId;
        ruleInstanceTVC.analysesId = self.selectedRuleSetId;
        ruleInstanceTVC.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"RuleSetFilesSegue"]) {
        INVRuleSetManageFilesContainerViewController *rulesetFilesTVC = segue.destinationViewController;
        rulesetFilesTVC.ruleSetId = self.selectedRuleSetId;
        rulesetFilesTVC.projectId = self.projectId;
    }
    if ([segue.identifier isEqualToString:@"AddRuleInstanceSegue"]) {
        INVRuleDefinitionsTableViewController *ruleDefnTVC = segue.destinationViewController;
        ruleDefnTVC.analysisId = self.selectedRuleSetId;
        ruleDefnTVC.createRuleInstanceDelegate = self;
    }
}

#pragma mark - accessor
- (INVRulesTableViewDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[INVRulesTableViewDataSource alloc] initWithFetchedResultsController:self.dataResultsController
                                                                               forTableView:self.tableView];
        INV_CellConfigurationBlock cellConfigurationBlock =
            ^(INVRuleInstanceTableViewCell *cell, id ruleSetManagedObject, NSIndexPath *indexPath) {
                INVRuleSet *ruleSet =
                    [MTLManagedObjectAdapter modelOfClass:[INVRuleSet class] fromManagedObject:ruleSetManagedObject error:nil];
                NSArray *ruleInstances = ruleSet.ruleInstances;
                NSInteger cellRow = indexPath.row;
                if (ruleInstances && ruleInstances.count > cellRow) {
                    INVRuleInstance *ruleInstance = [ruleInstances objectAtIndex:indexPath.row];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    /*
                     cell.name.text = ruleInstance.ruleName;
                    cell.overview.text = ruleInstance.overview;
                    cell.ruleInstanceId = ruleInstance.ruleInstanceId;
                    // cell.ruleSetId = ruleInstance.ruleSetId;
                    cell.actionDelegate = self;

                    cell.ruleWarning.hidden = ([ruleInstance.emptyParamCount integerValue] == 0);
                     */
                }
            };
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"RuleInstanceCell" configureBlock:cellConfigurationBlock];
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

- (NSFetchedResultsController *)dataResultsController
{
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = self.rulesManager.fetchRequestForRuleSets;
        NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"projectId==%@", self.projectId];
        [fetchRequest setPredicate:fetchPredicate];
        _dataResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                     managedObjectContext:self.rulesManager.managedObjectContext
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
        [_dataResultsController setDelegate:self];
        NSError *dbError = nil;
        [_dataResultsController performFetch:&dbError];
        if (dbError) {
            INVLogError(@"Perform fetch failed with %@", dbError);
            _dataResultsController = nil;
        }
    }
    return _dataResultsController;
}

#pragma mark - UISplitViewControllerDelegate

- (void)configureDisplayModeButton
{
    INVProjectListSplitViewController *splitVC = (INVProjectListSplitViewController *) self.splitViewController;

    if (splitVC.displayMode == UISplitViewControllerDisplayModeAllVisible) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = splitVC.displayModeButtonItem;
    }
    else {
        self.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureDisplayModeButton];
    });
}

#pragma mark - helpers
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

- (void)logRulesToConsole
{
    INVRuleSetArray ruleSetsForProject =
        [self.globalDataManager.invServerClient.rulesManager ruleSetsForProject:self.projectId];
    INVLogDebug(@"Rule sets for %@ is %@", self.projectId, ruleSetsForProject);

    [self.dataResultsController.fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleSet *ruleSet = obj;
        [ruleSet.ruleInstances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            INVLogDebug(@"Rule Instance for ruleset $%@ is %@\n", ruleSet.ruleSetId, obj);
        }];
    }];
}

@end
