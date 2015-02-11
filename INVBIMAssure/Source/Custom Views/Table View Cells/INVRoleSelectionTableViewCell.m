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
@property (strong) INVMembershipTypes membership;

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
    __block INVMembershipTypeDictionary memberType;
    [self.membership indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        memberType = obj;
        INV_MEMBERSHIP_TYPE type = (INV_MEMBERSHIP_TYPE)[memberType.allKeys[0] integerValue];
        return type == self.role;
    }];
    NSString *localStr = NSLocalizedString(memberType.allValues[0], nil);
    [self.currentRoleButton setTitle:localStr forState:UIControlStateNormal];

    //  [self.currentRoleButton setTitle:membershipTypeToString(_role) forState:UIControlStateNormal];
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

    INVMembershipTypeDictionary memberType = self.membership[indexPath.row];
    NSString *localStr = NSLocalizedString(memberType.allValues[0], nil);

    cell.textLabel.text = localStr;
    //  cell.textLabel.text = membershipTypeToString((INV_MEMBERSHIP_TYPE) indexPath.row);
    INV_MEMBERSHIP_TYPE type = (INV_MEMBERSHIP_TYPE)[memberType.allKeys[0] integerValue];

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

    INVMembershipTypeDictionary memberType = self.membership[indexPath.row];

    self.role = (INV_MEMBERSHIP_TYPE)[memberType.allKeys[0] integerValue];

    // self.role = (INV_MEMBERSHIP_TYPE) indexPath.row;

    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
