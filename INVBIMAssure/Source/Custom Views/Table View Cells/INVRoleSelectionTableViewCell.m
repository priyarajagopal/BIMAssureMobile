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

@interface INVRoleSelectionTableViewCell ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *currentRoleButton;
//@property (nonatomic, strong) INVMembershipTypeDictionary membership;
@property (nonatomic, strong) INVMembershipRoleArray roles;

- (IBAction)onRolesListSelected:(id)sender;

@end

@implementation INVRoleSelectionTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self fetchUserMembershipRoles];
  //  self.membership = [INVEmpireMobileClient membershipRoles];
  //  self.role = INV_MEMBERSHIP_TYPE_REGULAR;

    [self updateUI];
}

- (void)updateUI
{
    NSDictionary *descriptor = [self.role valueForKeyPath:@"descriptor"];
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *title = descriptor[languageCode][@"name"];
    
    [self.currentRoleButton setTitle:title forState:UIControlStateNormal];
}

- (void)setRole:(INVMembershipRole*)role
{
    _role = [role copy];
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

#pragma mark - server
- (void)fetchUserMembershipRoles
{
    [[INVGlobalDataManager sharedInstance]
            .invServerClient
        fetchUserMembershipRolesForSignedInAccountWithCompletionBlock:^(INVMembershipRoleArray roles, INVEmpireMobileError *error) {
            if (!error) {
                self.roles = roles;
                self.role = roles[0];
            }
            else {
                self.roles = @[];
            }
        }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.roles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"INVRoleCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"INVRoleCell"];
    }

#define _BACKEND_FIXED_
#ifdef _BACKEND_FIXED_
  
    INVMembershipRole *role = self.roles[indexPath.row];
    NSDictionary *descriptor = [role valueForKeyPath:@"descriptor"];
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *localStr = descriptor[languageCode][@"name"];
    cell.textLabel.text = localStr;
    INVMembershipRole* type = [role valueForKeyPath:@"roleId"];

    if (type == self.role) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

#else
    NSString *localStr = NSLocalizedString(self.membership[self.membership.allKeys[indexPath.row]], nil);

    cell.textLabel.text = localStr;
    INV_MEMBERSHIP_TYPE type = indexPath.row;

    if (type == self.role) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

#endif

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.role = self.roles[indexPath.row];

    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
