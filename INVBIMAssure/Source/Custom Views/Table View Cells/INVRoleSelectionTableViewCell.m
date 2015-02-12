//
//  INVRoleSelectionTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRoleSelectionTableViewCell.h"
#pragma mark - KVO
NSString *const KVO_INVRoleUpdated = @"role";

@interface INVRoleSelectionTableViewCell () <UITableViewDataSource, UITableViewDelegate>

@property (weak) IBOutlet UIButton *currentRoleButton;
@property (strong) INVMembershipTypeDictionary membership;

- (IBAction)onRolesListSelected:(id)sender;

@end

@implementation INVRoleSelectionTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.membership = [INVEmpireMobileClient membershipRoles];
    self.role = INV_MEMBERSHIP_TYPE_REGULAR;

    [self updateUI];
}

- (void)updateUI
{
    NSString *localStr = NSLocalizedString(self.membership[@(self.role)], nil);
    [self.currentRoleButton setTitle:localStr forState:UIControlStateNormal];
}

- (void)setRole:(INV_MEMBERSHIP_TYPE)role
{
    _role = role;

    [self updateUI];
}

- (void)onRolesListSelected:(id)sender
{
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.tableView.dataSource = self;
    tableViewController.tableView.delegate = self;

    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:tableViewController];
    popoverController.popoverContentSize = CGSizeMake(320, 240);

    [popoverController presentPopoverFromRect:self.currentRoleButton.bounds
                                       inView:self.currentRoleButton
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.membership.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"INVRoleCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"INVRoleCell"];
    }

    NSString *localStr = NSLocalizedString(self.membership[self.membership.allKeys[indexPath.row]], nil);

    cell.textLabel.text = localStr;
    INV_MEMBERSHIP_TYPE type = indexPath.row;

    if (type == self.role) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.role = [self.membership.allKeys[indexPath.row] intValue];

    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
