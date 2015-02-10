//
//  INVCurrentUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/26/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCurrentUsersTableViewController.h"
#import "UIView+INVCustomizations.h"
#import "INVUserProfileTableViewController.h"
#import "INVCurrentUsersProfileTableViewCell.h"
#import "INVBlockUtils.h"

@interface INVCurrentUsersTableViewController ()

@property IBOutlet INVTransitionToStoryboard *userProfileTransition;

@property (nonatomic, strong) NSFetchedResultsController *dataResultsController;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, strong) INVSignedInUser *signedInUser;

@property (nonatomic, strong) NSMutableDictionary *expanded;
@property (nonatomic, strong) NSMutableDictionary *cachedUsers;

- (void)showLoadProgress;

@end

@implementation INVCurrentUsersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.tableView.editing = YES;
    self.tableView.dataSource = [self dataSource];

    self.expanded = [NSMutableDictionary new];
    self.cachedUsers = [NSMutableDictionary new];

    UINib *userCellNib = [UINib nibWithNibName:@"INVCurrentUsersProfileTableViewCell" bundle:nil];
    [self.tableView registerNib:userCellNib forCellReuseIdentifier:@"UserCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;

    [self fetchListOfAccountMembers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRefreshControlSelected:(id)sender
{
    [self fetchListOfAccountMembers];
}

#pragma mark - server side
- (void)fetchListOfAccountMembers
{
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }

    [self.globalDataManager.invServerClient getMembershipForSignedInAccountWithCompletionBlock:INV_COMPLETION_HANDLER {
        INV_ALWAYS:
            [self.refreshControl endRefreshing];
            [self.hud hide:YES];

        INV_SUCCESS : {
            [self.dataResultsController performFetch:NULL];

            NSArray *objects = [self.dataResultsController.sections.firstObject objects];
            id successBlock = [INVBlockUtils blockForExecutingBlock:^{
                [self.tableView reloadData];
            } afterNumberOfCalls:objects.count];

            [objects enumerateObjectsUsingBlock:^(INVAccountMembership *membership, NSUInteger idx, BOOL *stop) {
                [self.globalDataManager.invServerClient
                    getUserProfileInSignedInAccountWithId:membership.userId
                                      withCompletionBlock:^(INVUser *user, INVEmpireMobileError *error) {
                                          self.cachedUsers[user.userId] = user;

                                          [successBlock invoke];
                                      }];
            }];
        }

        INV_ERROR : {
            UIAlertController *errController = [[UIAlertController alloc]
                initWithErrorMessage:NSLocalizedString(@"ERROR_FETCH_ACCOUNTMEMBERS", nil), error.code];
            [self presentViewController:errController animated:YES completion:nil];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [tableView beginUpdates];

    INVCurrentUsersProfileTableViewCell *profileCell =
        (INVCurrentUsersProfileTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    self.expanded[indexPath] = @(![self.expanded[indexPath] boolValue]);

    profileCell.expanded = [self.expanded[indexPath] boolValue];

    [tableView endUpdates];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"REMOVE", nil);
}

- (void)confirmDeletion:(NSIndexPath *)indexPath
{
    NSNumber *userId = [[self.dataResultsController objectAtIndexPath:indexPath] userId];

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER", nil)
                                            message:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER_NEGATIVE", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER_POSITIVE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          [self.globalDataManager.invServerClient
                                                              removeUserFromSignedInAccountWithUserId:userId
                                                                                  withCompletionBlock:INV_COMPLETION_HANDLER {
                                                                                      INV_ALWAYS:
                                                                                      INV_SUCCESS:
                                                                                      INV_ERROR:
                                                                                          INVLogError(@"%@", error);
                                                                                  }];
                                                      }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSFetchedResultsController *)dataResultsController
{
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = [self.globalDataManager.invServerClient.accountManager fetchRequestForAccountMembership];
        fetchRequest.sortDescriptors = [[NSArray
            arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"email"
                                                          ascending:YES
                                                         comparator:^NSComparisonResult(id obj1, id obj2) {
                                                             if ([obj1 isEqualToString:self.globalDataManager.loggedInUser])
                                                                 return NSOrderedAscending;

                                                             if ([obj2 isEqualToString:self.globalDataManager.loggedInUser])
                                                                 return NSOrderedDescending;

                                                             return NSOrderedSame;
                                                         }]] arrayByAddingObjectsFromArray:fetchRequest.sortDescriptors];

        _dataResultsController = [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.globalDataManager.invServerClient.accountManager.managedObjectContext
              sectionNameKeyPath:nil
                       cacheName:nil];

        NSError *dbError;
        [_dataResultsController performFetch:&dbError];

        if (dbError) {
            _dataResultsController = nil;
        }
    }

    return _dataResultsController;
}

- (INVGenericTableViewDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[INVGenericTableViewDataSource alloc] initWithFetchedResultsController:self.dataResultsController
                                                                                 forTableView:self.tableView];

        __weak typeof(self) weakSelf = self;

        _dataSource.editableHandler = ^BOOL(INVAccountMembership *member, NSIndexPath *_) {
            if (weakSelf.signedInUser) {
                return ![member.userId isEqualToNumber:weakSelf.signedInUser.userId];
            }

            return NO;
        };

        _dataSource.deletionHandler = ^(UITableViewCell *cell, INVAccountMembership *member, NSIndexPath *indexPath) {
            [weakSelf confirmDeletion:indexPath];
        };

        [_dataSource
            registerCellWithIdentifierForAllIndexPaths:@"UserCell"
                                        configureBlock:^(INVCurrentUsersProfileTableViewCell *cell,
                                                           INVAccountMembership *cellData, NSIndexPath *indexPath) {
                                            cell.user = self.cachedUsers[cellData.userId];
                                            cell.expanded = [self.expanded[indexPath] boolValue];

                                            if (cell.user == nil) {
                                                [self.globalDataManager.invServerClient
                                                    getUserProfileInSignedInAccountWithId:cellData.userId
                                                                      withCompletionBlock:^(id result,
                                                                                              INVEmpireMobileError *error) {
                                                                          cell.user = result;
                                                                      }];
                                            }
                                        }];
    }

    return _dataSource;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"userProfileTransition"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        INVUserProfileTableViewController *userProfileController =
            (INVUserProfileTableViewController *) navigationController.topViewController;
        userProfileController.userId = [[self.dataResultsController objectAtIndexPath:indexPath] userId];
    }
}
#pragma mark - helpers
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];
}

@end
