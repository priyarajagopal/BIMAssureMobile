//
//  INVAnalysesTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysesTableViewController.h"
#import "INVAnalysisTableViewCell.h"
#import "INVAnalysisEditViewController.h"
#import "INVAnalysisRulesTableViewController.h"
#import "INVAnalysisManageFilesContainerViewController.h"
#import "UIView+INVCustomizations.h"
#import "UISplitViewController+ToggleSidebar.h"

#import "INVProjectListSplitViewController.h"

@interface INVAnalysesTableViewController () <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *dataResultsController;
@property (nonatomic) BOOL isNSFetchedResultsChangeTypeUpdated;

@property (nonatomic) NSMutableDictionary *cachedHeigts;
@property (nonatomic) INVAnalysisTableViewCell *sizingCell;

- (IBAction)onEditAnalysis:(id)sender;
- (IBAction)onShowRulesForAnalysis:(id)sender;
- (IBAction)onRunRulesForAnalysis:(id)sender;
- (IBAction)onDeleteAnalysis:(id)sender;
- (IBAction)onPackageMembershipForAnalysis:(id)sender;
@end

@implementation INVAnalysesTableViewController

@synthesize dataResultsController = _dataResultsController;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    INVProjectListSplitViewController *splitVC = (INVProjectListSplitViewController *) self.splitViewController;
    [splitVC.aggregateDelegate removeDelegate:self];
    [splitVC.aggregateDelegate addDelegate:self];

    UINib *cellNib = [UINib nibWithNibName:@"INVAnalysisTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"analysisCell"];

    self.cachedHeigts = [NSMutableDictionary new];
    self.sizingCell = [[cellNib instantiateWithOwner:nil options:nil] firstObject];

    [self fetchListOfAnalyses];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureDisplayModeButton];
}

- (void)configureDisplayModeButton
{
    UISplitViewController *splitVC = self.splitViewController;
    self.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editAnalysis"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            INVAnalysisEditViewController *editVC =
                (INVAnalysisEditViewController *) [[segue destinationViewController] topViewController];
            editVC.analysis = sender;
        }
    }

    if ([[segue identifier] isEqualToString:@"createAnalysis"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            INVAnalysisEditViewController *editVC =
                (INVAnalysisEditViewController *) [[segue destinationViewController] topViewController];

            editVC.projectId = self.projectId;
        }
    }

    if ([[segue identifier] isEqual:@"showRules"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            INVAnalysisRulesTableViewController *rulesVC =
                (INVAnalysisRulesTableViewController *) [[segue destinationViewController] topViewController];

            rulesVC.projectId = self.projectId;
            rulesVC.analysisId = [sender analysisId];
        }
        else {
            INVAnalysisRulesTableViewController *rulesVC =
            (INVAnalysisRulesTableViewController *) [segue destinationViewController];
            
            rulesVC.projectId = self.projectId;
            rulesVC.analysisId = [sender analysisId];

        }
    }
    if ([[segue identifier] isEqual:@"AnalysisFilesSegue"]) {
        INVAnalysisManageFilesContainerViewController *aVC =
            (INVAnalysisManageFilesContainerViewController *) [segue destinationViewController];

        aVC.projectId = self.projectId;
        aVC.analysisId = [sender analysisId];
    }
}

#pragma mark - Content Management

- (void)onRefreshControlSelected:(id)sender
{
    [self fetchListOfAnalyses];
}

- (void)fetchListOfAnalyses
{
    id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.globalDataManager.invServerClient
        getAllAnalysesForProject:self.projectId
             withCompletionBlock:^(INVEmpireMobileError *error) {
                 INV_ALWAYS:
                     [hud hide:YES];
                     [self.refreshControl endRefreshing];

                 INV_SUCCESS:
                     [self.dataResultsController performFetch:NULL];
                     [self.tableView reloadData];

                 INV_ERROR:
                     INVLogError(@"%@", error);

                     UIAlertController *errorController =
                         [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSES_LOAD", nil)];
                     [self presentViewController:errorController animated:YES completion:nil];
             }];
}

- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *confirmController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ANALYSIS_TITLE", nil)
                                            message:NSLocalizedString(@"CONFIRM_DELETE_ANALYSIS_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [confirmController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ANALYSIS_NEGATIVE", nil)
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil]];

    [confirmController
        addAction:[UIAlertAction
                      actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ANALYSIS_POSITIVE", nil)
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction *action) {

                                  id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

                                  [self.globalDataManager.invServerClient
                                           deleteAnalyses:[[self.dataResultsController objectAtIndexPath:indexPath] analysisId]
                                      withCompletionBlock:INV_COMPLETION_HANDLER {
                                          INV_ALWAYS:
                                              [hud hide:YES];

                                          INV_SUCCESS:
                                          INV_ERROR:
                                              INVLogError(@"%@", error);

                                              UIAlertController *errorController = [[UIAlertController alloc]
                                                  initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSIS_DELETE", nil)];

                                              [self presentViewController:errorController animated:YES completion:nil];
                                      }];
                              }]];

    [self presentViewController:confirmController animated:YES completion:nil];
}

- (NSFetchedResultsController *)dataResultsController
{
    if (_dataResultsController == nil) {
        NSFetchRequest *fetchRequest = [self.globalDataManager.invServerClient.analysesManager fetchRequestForAnalyses];

        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"projectId = %@", self.projectId];
        fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES] ];

        _dataResultsController = [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.globalDataManager.invServerClient.analysesManager.managedObjectContext
              sectionNameKeyPath:nil
                       cacheName:nil];

        _dataResultsController.delegate = self;
    }

    return _dataResultsController;
}

#pragma mark - IBActions for INVAnalysisTableViewCell

- (void)onEditAnalysis:(id)sender
{
    INVAnalysisTableViewCell *cell = [sender findSuperviewOfClass:[INVAnalysisTableViewCell class] predicate:nil];

    [self performSegueWithIdentifier:@"editAnalysis" sender:cell.analysis];
}

- (void)onShowRulesForAnalysis:(id)sender
{
    INVAnalysisTableViewCell *cell = [sender findSuperviewOfClass:[INVAnalysisTableViewCell class] predicate:nil];

    [self performSegueWithIdentifier:@"showRules" sender:cell.analysis];
}

- (void)onDeleteAnalysis:(id)sender
{
    INVAnalysisTableViewCell *cell = [sender findSuperviewOfClass:[INVAnalysisTableViewCell class] predicate:nil];

    [self deleteRowAtIndexPath:[self.tableView indexPathForCell:cell]];
}

- (void)onRunRulesForAnalysis:(id)sender
{
    INVAnalysisTableViewCell *cell = [sender findSuperviewOfClass:[INVAnalysisTableViewCell class] predicate:nil];
    id analysis = cell.analysis;

    UIAlertController *confirmController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_ANALYSIS_RUN_TITLE", nil)
                                            message:NSLocalizedString(@"CONFIRM_ANALYSIS_RUN_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [confirmController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_ANALYSIS_RUN_NEGATIVE", nil)
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil]];

    [confirmController
        addAction:[UIAlertAction
                      actionWithTitle:NSLocalizedString(@"CONFIRM_ANALYSIS_RUN_POSITIVE", nil)
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {

                                  id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

                                  [self.globalDataManager.invServerClient
                                              runAnalysis:[analysis analysisId]
                                      WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                          INV_ALWAYS:
                                              [hud hide:YES];

                                          INV_SUCCESS : {
                                              UIAlertController *successController = [UIAlertController
                                                  alertControllerWithTitle:NSLocalizedString(
                                                                               @"ANALYSIS_EXECUTION_STARTED_TITLE", nil)
                                                                   message:NSLocalizedString(
                                                                               @"ANALYSIS_EXECUTION_STARTED_MESSAGE", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];

                                              [successController
                                                  addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                                     style:UIAlertActionStyleDefault
                                                                                   handler:nil]];

                                              [self presentViewController:successController animated:YES completion:nil];
                                          }

                                          INV_ERROR:
                                              INVLogError(@"%@", error);

                                              UIAlertController *errorController = [[UIAlertController alloc]
                                                  initWithErrorMessage:NSLocalizedString(@"ERROR_RUN_ANALYSIS", nil)];

                                              [errorController
                                                  addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                                     style:UIAlertActionStyleDefault
                                                                                   handler:nil]];

                                              [self presentViewController:errorController animated:YES completion:nil];
                                      }];

                              }]];

    [self presentViewController:confirmController animated:YES completion:nil];
}

- (void)onPackageMembershipForAnalysis:(id)sender
{
    INVAnalysisTableViewCell *cell = [sender findSuperviewOfClass:[INVAnalysisTableViewCell class] predicate:nil];

    [self performSegueWithIdentifier:@"AnalysisFilesSegue" sender:cell.analysis];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cachedHeigts[indexPath]) {
        return [self.cachedHeigts[indexPath] floatValue];
    }

    self.sizingCell.analysis = [self.dataResultsController objectAtIndexPath:indexPath];

    CGSize size = [self.sizingCell systemLayoutSizeFittingSize:CGSizeMake(tableView.bounds.size.width, 0)
                                 withHorizontalFittingPriority:UILayoutPriorityRequired
                                       verticalFittingPriority:UILayoutPriorityDefaultLow];

    self.cachedHeigts[indexPath] = @(size.height);

    return size.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataResultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVAnalysisTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"analysisCell"];
    cell.analysis = [self.dataResultsController objectAtIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    if (indexPath) {
        [self.cachedHeigts removeObjectForKey:indexPath];
    }

    switch (type) {
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
    [self.cachedHeigts removeAllObjects];
}

@end