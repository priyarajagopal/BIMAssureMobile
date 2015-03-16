//
//  INVAnalysesTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysesTableViewController.h"
#import "INVAnalysisTableViewCell.h"

#import "UISplitViewController+ToggleSidebar.h"
#import "INVProjectListSplitViewController.h"

@interface INVAnalysesTableViewController () <UISplitViewControllerDelegate>

@property (nonatomic) NSFetchedResultsController *dataResultsController;

@end

@implementation INVAnalysesTableViewController

@synthesize dataResultsController = _dataResultsController;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:@"INVAnalysisTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"analysisCell"];

    INVProjectListSplitViewController *splitVC = (INVProjectListSplitViewController *) self.splitViewController;
    [splitVC.aggregateDelegate addDelegate:self];

    [self fetchListOfAnalyses];
    [self configureDisplayModeButton];
}

- (void)configureDisplayModeButton
{
    UISplitViewController *splitVC = self.splitViewController;

    if (splitVC.displayMode == UISplitViewControllerDisplayModeAllVisible) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = splitVC.displayModeButtonItem;
    }
    else {
        self.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"analysisDetails"]) {
        if (self.splitViewController.displayMode == UISplitViewControllerDisplayModeAllVisible) {
            [self.splitViewController toggleSidebar];
        }
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

- (NSFetchedResultsController *)dataResultsController
{
    if (_dataResultsController == nil) {
        NSFetchRequest *fetchRequest = [self.globalDataManager.invServerClient.analysesManager fetchRequestForAnalyses];
        fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES] ];

        _dataResultsController = [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.globalDataManager.invServerClient.analysesManager.managedObjectContext
              sectionNameKeyPath:nil
                       cacheName:nil];
    }

    return _dataResultsController;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
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
                                         handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

                                         }],
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                           title:NSLocalizedString(@"EDIT", nil)
                                         handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

                                         }],
    ];
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self performSegueWithIdentifier:@"analysisDetails" sender:[self.dataResultsController objectAtIndexPath:indexPath]];
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureDisplayModeButton];
    });
}

@end