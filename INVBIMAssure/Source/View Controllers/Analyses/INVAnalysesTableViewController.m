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

#import "UIView+INVCustomizations.h"
#import "UISplitViewController+ToggleSidebar.h"

#import "INVProjectListSplitViewController.h"

@interface INVAnalysesTableViewController () <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *dataResultsController;
@property (nonatomic) BOOL isNSFetchedResultsChangeTypeUpdated;
@property (nonatomic) NSIndexPath *indexOfProjectBeingEdited;

@property (nonatomic) NSMutableDictionary *cachedHeigts;
@property (nonatomic) INVAnalysisTableViewCell *sizingCell;

- (IBAction)onShowRulesForAnalysis:(id)sender;

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
        INVAnalysisEditViewController *editVC =
            (INVAnalysisEditViewController *) [[segue destinationViewController] topViewController];

        editVC.analysis = sender;
    }

    if ([[segue identifier] isEqualToString:@"createAnalysis"]) {
        INVAnalysisEditViewController *editVC =
            (INVAnalysisEditViewController *) [[segue destinationViewController] topViewController];

        editVC.projectId = self.projectId;
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
                     [self.cachedHeigts removeAllObjects];
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

- (void)reloadRowAtSelectedIndex
{
    [self.cachedHeigts removeObjectForKey:self.indexOfProjectBeingEdited];
    [self.tableView reloadRowsAtIndexPaths:@[ self.indexOfProjectBeingEdited ]
                          withRowAnimation:UITableViewRowAnimationAutomatic];

    self.indexOfProjectBeingEdited = nil;
}

#pragma mark - IBActions

- (void)onShowRulesForAnalysis:(id)sender
{
    INVAnalysisTableViewCell *cell = [sender findSuperviewOfClass:[INVAnalysisTableViewCell class] predicate:nil];

    INVLogDebug(@"%@", [[cell analysis] rules]);
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

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                           title:NSLocalizedString(@"DELETE", nil)
                                         handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                             [self deleteRowAtIndexPath:indexPath];
                                         }],
        [UITableViewRowAction
            rowActionWithStyle:UITableViewRowActionStyleNormal
                         title:NSLocalizedString(@"EDIT", nil)
                       handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                           self.indexOfProjectBeingEdited = indexPath;

                           [self performSegueWithIdentifier:@"editAnalysis"
                                                     sender:[self.dataResultsController objectAtIndexPath:indexPath]];
                       }],
    ];
}

- (void)tableView:(UITableView *)tableView
         commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
          forRowAtIndexPath:(NSIndexPath *)indexPath{}

                            - (void)
                  tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Note on special case:
    // The project notifications periodically fetches the projects list in the background. This results in the local cache
    // getting updated with GET results - anytime the core data cache is touched, the
    // NSFetchedResultsController delegate is notified. The GET may not may not result in a change so we do not want to keep
    // reloading the data.
    // if the user has manually triggered a refresh or the view is loaded, the table view is reloaded.
    if (!self.isNSFetchedResultsChangeTypeUpdated) {
        [self.cachedHeigts removeAllObjects];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    else if (self.indexOfProjectBeingEdited) {
        [self performSelectorOnMainThread:@selector(reloadRowAtSelectedIndex) withObject:nil waitUntilDone:NO];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    self.isNSFetchedResultsChangeTypeUpdated = (type == NSFetchedResultsChangeUpdate);
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
    [self.cachedHeigts removeAllObjects];
}

@end