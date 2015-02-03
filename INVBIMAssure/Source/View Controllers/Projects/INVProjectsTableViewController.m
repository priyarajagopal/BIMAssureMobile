//
//  INVProjectsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectsTableViewController.h"
#import "INVProjectTableViewCell.h"
#import "INVProjectDetailsTabViewController.h"
#import "INVProjectFilesListViewController.h"
#import "INVProjectEditViewController.h"
#import "INVRulesListViewController.h"
#import "INVProjectListSplitViewController.h"
#import "INVRuleExecutionsTableViewController.h"
#import "UIImage+INVCustomizations.h"
#import "INVPagingManager+ProjectListing.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 300;
static const NSInteger TABINDEX_PROJECT_FILES = 0;
static const NSInteger TABINDEX_PROJECT_RULESETS = 1;
static const NSInteger DEFAULT_FETCH_PAGE_SIZE = 100;

@interface INVProjectsTableViewController () <INVProjectTableViewCellDelegate, INVProjectEditViewControllerDelegate,
    INVPagingManagerDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, readwrite) NSFetchedResultsController *dataResultsController;
@property (nonatomic, strong) INVProjectManager *projectManager;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) INVProjectDetailsTabViewController *projectDetailsController;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, strong) INVPagingManager *projectPagingManager;
@property (nonatomic, weak) UILabel *updatedAtLabel;
@property (nonatomic, assign) BOOL isNSFetchedResultsChangeTypeUpdated;
@end

@implementation INVProjectsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"PROJECTS", nil);

    self.clearsSelectionOnViewWillAppear = NO;
    self.projectPagingManager = [[INVPagingManager alloc] initWithPageSize:DEFAULT_FETCH_PAGE_SIZE delegate:self];

    UINib *nib = [UINib nibWithNibName:@"INVProjectTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ProjectCell"];

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.dataSource = self.dataSource;
    [self fetchProjectList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.navigationController.toolbarHidden) {
        UIToolbar *toolbar = self.navigationController.toolbar;

        UILabel *label = [[UILabel alloc]
            initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(toolbar.frame))];
        [label setTintColor:[UIColor darkGrayColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:13.0]];

        self.updatedAtLabel = label;

        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
        [buttonItem setTintColor:[UIColor blackColor]];
        [self.navigationController.visibleViewController setToolbarItems:@[ buttonItem ]];

        [self.navigationController setToolbarHidden:NO animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.projectManager = nil;
    self.dateFormatter = nil;
    self.projectDetailsController = nil;
}

- (void)onRefreshControlSelected:(id)event
{
    [self fetchProjectList];
}

- (void)setSelectedProject:(INVProject *)project
{
    NSIndexPath *indexPath = [self.dataResultsController indexPathForObject:project];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];

    [self performSegueWithIdentifier:@"ProjectDetailSegue" sender:nil];
}

#pragma mark - server side
- (void)fetchProjectList
{
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }

    [self.projectPagingManager resetOffset];
    [self.projectPagingManager fetchProjectsFromCurrentOffset];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ProjectDetailSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataResultsController.fetchedObjects.count - indexPath.row == DEFAULT_FETCH_PAGE_SIZE / 4) {
        INVLogDebug(@"Will fetch next batch");

        [self.projectPagingManager fetchProjectsFromCurrentOffset];
    }
}

#pragma mark - Navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"ProjectDetailSegue"]) {
        INVProject *project = [self.dataResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];

        INVProjectDetailsTabViewController *projectDetailsController =
            (INVProjectDetailsTabViewController *) segue.destinationViewController;

        INVTabBarStoryboardLoader *tabStoryBoardLoader = projectDetailsController.storyboardTransitionObject;
        UINavigationController *navController = tabStoryBoardLoader.tabBarController.viewControllers[TABINDEX_PROJECT_FILES];
        INVProjectFilesListViewController *fileListController =
            (INVProjectFilesListViewController *) navController.topViewController;

        fileListController.projectId = project.projectId;

        UINavigationController *rsNavController =
            tabStoryBoardLoader.tabBarController.viewControllers[TABINDEX_PROJECT_RULESETS];
        ;
        INVRulesListViewController *ruleSetController = (INVRulesListViewController *) rsNavController.topViewController;

        ruleSetController.projectId = project.projectId;
    }

    if ([segue.identifier isEqualToString:@"editProject"]) {
        UINavigationController *editNavigationController = [segue destinationViewController];
        INVProjectEditViewController *editViewController = [[editNavigationController viewControllers] firstObject];
        editViewController.delegate = self;

        if ([sender isKindOfClass:[INVProjectTableViewCell class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            INVProject *project = [self.dataResultsController objectAtIndexPath:indexPath];

            editViewController.currentProject = project;
        }
        else {
            editViewController.currentProject = nil;
        }
    }
}

#pragma mark - helper
- (void)showLoadProgress
{
    [self.updatedAtLabel setText:NSLocalizedString(@"UPDATING", nil)];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)updateTimeStamp
{
    [self.updatedAtLabel setText:[NSString stringWithFormat:NSLocalizedString(@"UPDATED_AT", nil),
                                           [self.dateFormatter stringFromDate:[NSDate date]]]];
}
#pragma mark - INVPagingManagerDelegate

- (void)onFetchedDataAtOffset:(NSInteger)offset pageSize:(NSInteger)size withError:(INVEmpireMobileError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    void (^failureBlock)(NSInteger errorCode) = ^(NSInteger errorCode) {
        if (errorCode != INV_ERROR_CODE_NOMOREPAGES) {
            UIAlertController *errController =
                [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_PROJECTS_LOAD", nil), error];
            [self presentViewController:errController animated:YES completion:nil];
            ;
        }
    };
    [self performSelectorOnMainThread:@selector(updateTimeStamp) withObject:nil waitUntilDone:NO];
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
    // Note: need to explicitly do a fetch because our notification poller keeps polling for the same information from server
    //  updating the persistent store. This implies that there is a chance that when the projects view
    // requests the data,there are no changes to the persistent store- so any faulted objects go out of sync
    // with whats in the persistent store. The stalenessInterval property does not help since the persistent store
    // is not updated in this case. This is a race condition between when the poller fetches the data thereby upating the store
    // versus when the projects viewer requests this. Regardless, forcing a fetch by the FRC will ensure that
    // the in-memory version syncs up with the data store

    if (!error) {
        NSError *dbError;
        [self.dataResultsController performFetch:&dbError];
        if (dbError) {
            failureBlock(dbError.code);
        }

        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    else {
        failureBlock(error.code.integerValue);
    }
}

#pragma mark - accessor
- (INVGenericTableViewDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[INVGenericTableViewDataSource alloc] initWithFetchedResultsController:self.dataResultsController
                                                                                 forTableView:self.tableView];

        INV_CellConfigurationBlock cellConfigurationBlock =
            ^(INVProjectTableViewCell *cell, INVProject *project, NSIndexPath *indexPath) {

                cell.delegate = self;
                cell.projectId = project.projectId;
                cell.name.text = project.name;

                [self.globalDataManager.invServerClient
                    getTotalCountOfPkgMastersForProject:project.projectId
                                    WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                        if (error)
                                            return;

                                        cell.fileCount.text = [NSString stringWithFormat:@"\uf0c5 %d", [result intValue]];
                                    }];

                // TODO: Load this from a cache first?
                cell.fileCount.text = @"\uf0c5 0";
                cell.userCount.text = @"\uf0c0 0";

                NSString *createdOnStr = NSLocalizedString(@"CREATED_ON", nil);
                NSString *createdOnWithDateStr = [NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"CREATED_ON", nil),
                                                           [self.dateFormatter stringFromDate:project.createdAt]];
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:createdOnWithDateStr];
                [attrString addAttribute:NSForegroundColorAttributeName
                                   value:[UIColor darkTextColor]
                                   range:NSMakeRange(0, createdOnStr.length - 1)];
                [attrString addAttribute:NSForegroundColorAttributeName
                                   value:[UIColor lightGrayColor]
                                   range:NSMakeRange(createdOnStr.length, createdOnWithDateStr.length - createdOnStr.length)];

                cell.createdOnLabel.attributedText = attrString;
            
#warning This shoud eventually be provided as a selected by user during project creation and should subsequently be pulled from server. If user does not select one, we randomly pick one
                NSInteger index = indexPath.section % 5; // We have 5 canned images
                NSString *thumbnail = [NSString stringWithFormat:@"project_thumbnail_%ld", (long) index];
                UIImage *tempImage = [UIImage imageNamed:thumbnail];
                cell.thumbnailImageView.image = [UIImage resizeImage:tempImage toSize:cell.thumbnailImageView.frame.size];
            };
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"ProjectCell" configureBlock:cellConfigurationBlock];
    }
    return _dataSource;
}

- (INVProjectManager *)projectManager
{
    if (!_projectManager) {
        _projectManager = self.globalDataManager.invServerClient.projectManager;
    }
    return _projectManager;
}

- (NSFetchedResultsController *)dataResultsController
{
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = [self.projectManager.fetchRequestForProjects copy];
        fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO] ];

        _dataResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:self.projectManager.managedObjectContext
                                                  sectionNameKeyPath:@"projectId"
                                                           cacheName:nil];
        _dataResultsController.delegate = self;
        NSError *dbError;
        [_dataResultsController performFetch:&dbError];

        if (dbError) {
            _dataResultsController = nil;
        }
    }
    return _dataResultsController;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

- (void)onProjectDeleted:(INVProjectTableViewCell *)sender
{
    NSNumber *projectId = sender.projectId;

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_DELETE_PROJECT", nil)
                                            message:NSLocalizedString(@"CONFIRM_DELETE_PROJECT_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_PROJECT_CONFIRM_NEGATIVE", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];

    [alertController
        addAction:[UIAlertAction
                      actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_PROJECT_CONFIRM_POSITIVE", nil)
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction *action) {
                                  [self.globalDataManager.invServerClient
                                                        deleteProjectWithId:projectId
                                      ForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
                                          if (error) {
                                              // The local cache should have updated on a delete and should be reflected in
                                              // update to fetchresultscontroller
                                              if (error.code.integerValue != INV_ERROR_CODE_NOMOREPAGES) {
                                                  UIAlertController *errController = [[UIAlertController alloc]
                                                      initWithErrorMessage:NSLocalizedString(@"ERROR_PROJECTS_DELETE", nil),
                                                      error.code.integerValue];
                                                  [self presentViewController:errController animated:YES completion:nil];
                                              }
                                          }
                                      }];
                              }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)onProjectEdited:(INVProjectTableViewCell *)sender
{
    [self performSegueWithIdentifier:@"editProject" sender:sender];
}

- (void)onProjectEditSaved:(INVProjectEditViewController *)controller
{
    // Since are not supporting updates via didChangeObject.... callback
    [self fetchProjectList];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Note on special case:
    // The project notifications periodically fetches the projects list in the background. This results in the local cache
    // getting updated with GET results - anytime the core data cache is touched, the
    // NSFetchedResultsController delegate is notified. The GET may not may not result in a change so we do not want to keep
    // reloading the data.
    // if the user has manually triggered a refresh or the view is loaded, the table view is reloaded.
    if (!self.isNSFetchedResultsChangeTypeUpdated) {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type
{
}

@end
