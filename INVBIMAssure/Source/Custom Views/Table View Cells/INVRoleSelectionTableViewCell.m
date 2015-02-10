//
//  INVRoleSelectionTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRoleSelectionTableViewCell.h"

static inline NSString *membershipTypeToString(INV_MEMBERSHIP_TYPE type)
{
    static NSString *localizedKeys[] = { @"INV_MEMBERSHIP_TYPE_USER", @"INV_MEMBERSHIP_TYPE_ADMIN" };

    return NSLocalizedString(localizedKeys[type], nil);
}

@interface INVRoleSelectionTableViewCell () <UITableViewDataSource, UITableViewDelegate>

@property (weak) IBOutlet UIButton *currentRoleButton;

- (IBAction)onRolesListSelected:(id)sender;

@end

@implementation INVRoleSelectionTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self updateUI];
}

- (void)updateUI
{
    [self.currentRoleButton setTitle:membershipTypeToString(_role) forState:UIControlStateNormal];
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"INVRoleCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"INVRoleCell"];
    }

    cell.textLabel.text = membershipTypeToString((INV_MEMBERSHIP_TYPE) indexPath.row);

    if (indexPath.row == self.role) {
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

    self.role = (INV_MEMBERSHIP_TYPE) indexPath.row;

    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
