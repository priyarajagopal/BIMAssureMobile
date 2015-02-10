//
//  INVCurrentUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/26/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCurrentUsersTableViewController.h"

@interface INVCurrentUsersTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *dataResultsController;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, strong) INVSignedInUser* signedInUser;
- (void)showLoadProgress;

@end

@implementation INVCurrentUsersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.tableView.editing = YES;
    self.tableView.dataSource = [self dataSource];
    [self fetchSignedInUserProfile];
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

        INV_SUCCESS:
            [self.tableView reloadData];

        INV_ERROR : {
            UIAlertController *errController = [[UIAlertController alloc]
                initWithErrorMessage:NSLocalizedString(@"ERROR_FETCH_ACCOUNTMEMBERS", nil), error.code];
            [self presentViewController:errController animated:YES completion:nil];
        }
    }];
}

-(void)fetchSignedInUserProfile {
    [self.globalDataManager.invServerClient
     getSignedInUserProfileWithCompletionBlock:^(id result, INVEmpireMobileError *error) {
         if (!error) {
              self.signedInUser = (INVSignedInUser *) result;
         }
         else {
             self.signedInUser = nil;
         }
     }];
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        _dataResultsController.delegate = self;
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
            registerCellWithIdentifierForAllIndexPaths:
                @"UserCell" configureBlock:^(UITableViewCell *cell, INVAccountMembership *member, NSIndexPath *indexPath) {

                [self.globalDataManager.invServerClient
                    getUserProfileInSignedInAccountWithId:member.userId
                                      withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                          if (error) {
                                              cell.textLabel.text = NSLocalizedString(@"ERROR_LOAD_USER_PROFILE", nil);
                                              cell.indentationLevel = 0;
                                              cell.indentationWidth = 0;
                                          }
                                          else {
                                              INVUser *user = result;
                                              cell.textLabel.text =
                                                  [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                                              cell.detailTextLabel.text = user.email;
                                              if (weakSelf.dataSource.editableHandler(user, indexPath)) {
                                                  cell.indentationLevel = 0;
                                                  cell.indentationWidth = 0;
                                              }
                                              else {
                                                  cell.indentationLevel = 1;
                                                  cell.indentationWidth = 38;
                                              }
                                          }
                                      }];

            }];
    }

    return _dataSource;
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
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
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
