//
//  INVUserManagementTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/22/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVUserManagementTableViewController.h"
#import "INVInviteUsersTableViewController.h"

@interface INVUserManagementTableViewController ()

@property IBOutlet UILabel *accountNameLabel;

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

    self.accountNameLabel.text = [self accountNameForAccountId:self.globalDataManager.loggedInAccount];
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)accountNameForAccountId:(NSNumber *)accountId
{
    INVAccountArray accounts = [self.globalDataManager.invServerClient.accountManager accountsOfSignedInUser];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"accountId==%@", accountId];
    NSArray *matches = [accounts filteredArrayUsingPredicate:pred];
    if (matches && matches.count) {
        INVAccount *match = matches[0];
        return match.name;
    }
    return nil;
}

@end
