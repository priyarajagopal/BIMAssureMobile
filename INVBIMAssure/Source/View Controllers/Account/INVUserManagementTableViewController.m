//
//  INVUserManagementTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/22/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVUserManagementTableViewController.h"
#import "INVInviteUsersTableViewController.h"
#import "INVCreateAccountViewController.h"

#define ROW_ACCOUNT_MEMBERS 0
#define ROW_PENDING_INVITES 1
#define ROW_INVITE_USERS 2
#define ROW_EDIT_ACCOUNT 3
#define ROW_DISABLE_ACCOUNT 4

@interface INVUserManagementTableViewController ()

@property IBOutlet UILabel *accountNameLabel;
@property IBOutlet INVTransitionToStoryboard *editAccountTransition;

@end

@implementation INVUserManagementTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"USER_MANAGEMENT_ACCOUNT", nil);
    self.refreshControl = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.accountNameLabel.text = [self loggedInAccount].name;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditAccountSegue"]) {
        UINavigationController *navController = [segue destinationViewController];
        INVCreateAccountViewController *createAccountController =
            (INVCreateAccountViewController *) [navController topViewController];

        createAccountController.accountToEdit = [self loggedInAccount];
    }
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == ROW_EDIT_ACCOUNT) {
        [self.editAccountTransition perform:nil];
    }

    if (indexPath.row == ROW_DISABLE_ACCOUNT) {
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:NSLocalizedString(@"DISABLE_ACCOUNT_TITLE", nil)
                                                message:NSLocalizedString(@"DISABLE_ACCOUNT_MESSAGE", nil)
                                         preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"DISABLE_ACCOUNT_CANCEL_TITLE", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];

        [alertController
            addAction:[UIAlertAction
                          actionWithTitle:NSLocalizedString(@"DISABLE_ACCOUNT_PERFORM_TITLE", nil)
                                    style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action) {
                                      [self.globalDataManager.invServerClient
                                          disableAccountForSignedInUserWithCompletionBlock:INV_COMPLETION_HANDLER {
                                              INV_ALWAYS:
                                              INV_SUCCESS : {
                                                  [self.globalDataManager.invServerClient
                                                      logOffSignedInAccountWithCompletionBlock:INV_COMPLETION_HANDLER {
                                                          INV_ALWAYS:
                                                          INV_SUCCESS:
                                                              self.globalDataManager.loggedInAccount = nil;
                                                              [self.globalDataManager deleteCurrentlySavedDefaultAccountFromKC];
                                                              [self notifyAccountLogout];

                                                          INV_ERROR:
                                                              INVLogError(@"%@", error);
                                                              [self presentDisableErrorMessage];
                                                      }];
                                              }

                                              INV_ERROR:
                                                  INVLogError(@"%@", error);
                                                  [self presentDisableErrorMessage];
                                          }];

                                  }]];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)notifyAccountLogout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INV_NotificationAccountLogOutSuccess object:nil userInfo:nil];
}

- (void)presentDisableErrorMessage
{
    UIAlertController *errorController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR_ACCOUNT_DISABLE_TITLE", nil)
                                            message:NSLocalizedString(@"ERROR_ACCOUNT_DISABLE_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [errorController
        addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];

    [self presentViewController:errorController animated:YES completion:nil];
}

- (INVAccount *)loggedInAccount
{
    INVAccountArray accounts = [self.globalDataManager.invServerClient.accountManager accountsOfSignedInUser];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"accountId==%@", self.globalDataManager.loggedInAccount];
    NSArray *matches = [accounts filteredArrayUsingPredicate:pred];

    return [matches firstObject];
}

@end
