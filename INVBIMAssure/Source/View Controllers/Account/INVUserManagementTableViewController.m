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
}

- (INVAccount *)loggedInAccount
{
    INVAccountArray accounts = [self.globalDataManager.invServerClient.accountManager accountsOfSignedInUser];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"accountId==%@", self.globalDataManager.loggedInAccount];
    NSArray *matches = [accounts filteredArrayUsingPredicate:pred];

    return [matches firstObject];
}

@end
