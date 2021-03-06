//
//  INVInviteUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/24/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVInviteUsersTableViewController.h"
#import "INVTextViewTableViewCell.h"
#import "INVTokensTableViewCell.h"
#import "UIView+INVCustomizations.h"
#import "INVRoleSelectionTableViewCell.h"

@import AddressBookUI;

static const NSInteger DEFAULT_MESSAGE_CELL_HEIGHT = 200;
static const NSInteger DEFAULT_INVITEDUSERS_CELL_HEIGHT = 100;
static const NSInteger DEFAULT_ROLE_CELL_HEIGHT = 50;

static const NSInteger DEFAULT_NUM_ROWS_SECTION = 1;
static const NSInteger DEFAULT_NUM_SECTIONS = 3;

static const NSInteger SECTIONINDEX_INVITEUSERLIST = 0;
static const NSInteger SECTIONINDEX_ROLE = 1;
static const NSInteger SECTIONINDEX_MESSAGE = 2;

static const NSInteger DEFAULT_HEADER_HEIGHT = 40;

@interface INVInviteUsersTableViewController () <INVTextViewTableViewCellDelegate, INVTokensTableViewCellDelegate,
    ABPeoplePickerNavigationControllerDelegate>
@property (nonatomic, strong) INVAccountManager *accountManager;
@property (nonatomic, assign) NSInteger messageRowHeight;
@property (nonatomic, weak) INVTokensTableViewCell *inviteUsersCell;
@property (nonatomic, assign) INV_MEMBERSHIP_TYPE role;
@property (nonatomic, copy)INVProjectArray selectedProjects;
@property (nonatomic, copy)NSString* customMessage;
@end

@implementation INVInviteUsersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"INVITE_USERS", nil);

    self.refreshControl = nil;
    self.messageRowHeight = DEFAULT_MESSAGE_CELL_HEIGHT;

    UINib *nib = [UINib nibWithNibName:@"INVTextViewTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MessageTextCell"];

    UINib *roleNib = [UINib nibWithNibName:@"INVRoleSelectionTableViewCell" bundle:nil];
    [self.tableView registerNib:roleNib forCellReuseIdentifier:@"RoleSelectionCell"];

    UINib *inviteNib = [UINib nibWithNibName:@"INVTokensTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:inviteNib forCellReuseIdentifier:@"InviteUserCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.clearsSelectionOnViewWillAppear = YES;
    
    
    //self.role = INV_MEMBERSHIP_TYPE_REGULAR;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.accountManager = nil;

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SECTIONINDEX_ROLE]];
    [cell removeObserver:self forKeyPath:@"role"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return DEFAULT_NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return DEFAULT_NUM_ROWS_SECTION;
}

- (IBAction)displayPeoplePickerController:(id)sender
{
    // Hide the keyboard.
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:self forEvent:nil];

    ABPeoplePickerNavigationController *peoplePickerController = [[ABPeoplePickerNavigationController alloc] init];
    peoplePickerController.displayedProperties = @[ @(kABPersonEmailProperty) ];

    peoplePickerController.modalPresentationStyle = UIModalPresentationPopover;
    peoplePickerController.peoplePickerDelegate = self;

    [self presentViewController:peoplePickerController animated:YES completion:nil];

    peoplePickerController.popoverPresentationController.sourceView = sender;
    peoplePickerController.popoverPresentationController.sourceRect = [sender bounds];

    peoplePickerController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTIONINDEX_INVITEUSERLIST) {
        INVTokensTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteUserCell"];
        CGRect currFrame = cell.tokenField.frame;
        currFrame.size.width = tableView.frame.size.width;
        cell.tokenField.frame = currFrame;
        cell.cellDelegate = self;
        self.inviteUsersCell = cell;
        return cell;
    }

    if (indexPath.section == SECTIONINDEX_ROLE) {
        INVRoleSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoleSelectionCell"];
        [cell addObserver:self forKeyPath:KVO_INVRoleUpdated options:NSKeyValueObservingOptionNew context:NULL];

        return cell;
    }

    if (indexPath.section == SECTIONINDEX_MESSAGE) {
        INVTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageTextCell"];
        cell.cellDelegate = self;

        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return DEFAULT_HEADER_HEIGHT;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *) view;
    headerFooterView.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTIONINDEX_MESSAGE) {
        return self.messageRowHeight;
    }
    else if (indexPath.section == SECTIONINDEX_ROLE) {
        return DEFAULT_ROLE_CELL_HEIGHT;
    }
    else if (indexPath.section == SECTIONINDEX_INVITEUSERLIST) {
        return DEFAULT_INVITEDUSERS_CELL_HEIGHT;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SECTIONINDEX_MESSAGE) {
        return NSLocalizedString(@"ENTER_OPTIONAL_MESSAGE", nil);
    }
    if (section == SECTIONINDEX_INVITEUSERLIST) {
        return NSLocalizedString(@"ENTER_INVITED_USERS", nil);
    }

    return nil;
}

#pragma mark - INVTextViewTableViewCellDelegate
- (void)cellSizeChanged:(CGSize)size withTextString:(NSString *)textStr
{
    [self.tableView beginUpdates];
    self.messageRowHeight = size.height;
    self.customMessage = textStr;
    [self.tableView endUpdates];
}

#pragma mark - INVTokensTableViewCellDelegate
- (void)tokensChanged:(NSArray *)inputTokens
{
    [self.sendButton setEnabled:inputTokens.count > 0];
}
- (IBAction)onSendClicked:(id)sender
{
    self.hud = [MBProgressHUD generalViewHUD:NSLocalizedString(@"INVITING", nil)];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    [self inviteUsers:[self cleanupTokens:self.inviteUsersCell.tokens] withMessage:self.customMessage];
}

#pragma mark - server side
- (void)inviteUsers:(NSArray *)users withMessage:(NSString *)message
{
    // HARDCODE ALERT: When UI is finalized, have option to accept projects , roles on per user basis .
    // For now, just invite users to all projects and all invitees
    // have same role
    INVInviteMutableArray invites = [[NSMutableArray alloc]initWithCapacity:0];
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVInvite* invitee = [[INVInvite alloc]init];
        invitee.email = obj;
        invitee.roles = @[@(self.role)];
        invitee.context = [[INVContext alloc]init];
        invitee.context.projects = self.selectedProjects;
        invitee.messageBody = message;
        [invites addObject:invitee];

    }];
      [self.globalDataManager.invServerClient
        inviteUsersToSignedInAccount:invites
                 withCompletionBlock:^(INVEmpireMobileError *error) {
                     [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

                     if (error) {
                         INVLogError(@"%@", error);
 
                         [self showInviteFailureAlert];
                     }
                     else {
                         [self performSegueWithIdentifier:@"ReturnToUserManagementSegue" sender:self];
                     }
                 }];
}

#pragma mark - accessors
- (INVAccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = self.globalDataManager.invServerClient.accountManager;
    }
    return _accountManager;
}

-(INVProjectArray)selectedProjects {
    // HARDCOD ALERT. THis has to be selected via UI. For now, just hardcode entire projects array so users invited to all projects
    if (!_selectedProjects) {
        _selectedProjects = [[self.globalDataManager.invServerClient.projectManager projectsInAccount]valueForKey:@"projectId"];
    }
    return _selectedProjects;
    
}
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:KVO_INVRoleUpdated] && [object isKindOfClass:[INVRoleSelectionTableViewCell class]]) {
        //  Role changed
        INVRoleSelectionTableViewCell *cell = (INVRoleSelectionTableViewCell *) object;
        self.role = cell.role.roleId.integerValue;
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    ABMutableMultiValueRef emails = ABRecordCopyValue(person, property);
    CFStringRef selectedEmail = ABMultiValueCopyValueAtIndex(emails, ABMultiValueGetIndexForIdentifier(emails, identifier));
    NSString *asNSString = (__bridge_transfer NSString *) selectedEmail;

    CFRelease(emails);

    if ([asNSString isValidEmail]) {
        [self.inviteUsersCell.tokens addObject:asNSString];
        [self.inviteUsersCell reloadData];

        [self tokensChanged:self.inviteUsersCell.tokens];
    }
    else {
// TODO: Explain invalid email
#warning Show alert that email is invalid
    }
}

#pragma mark - helpers
- (NSArray *)cleanupTokens:(NSArray *)tokens
{
    NSMutableArray *cleanTokens = [[NSMutableArray alloc] initWithCapacity:0];
    [tokens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *token = obj;
        token = [token stringByReplacingOccurrencesOfString:@"," withString:@""];
        [cleanTokens addObject:token];
    }];
    return cleanTokens;
}
- (void)showInviteFailureAlert
{
    UIAlertController *inviteFailureAlertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INVITE_FAILURE", nil)
                                            message:NSLocalizedString(@"GENERIC_INVITE_FAILURE_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];

    [inviteFailureAlertController addAction:action];
    [self presentViewController:inviteFailureAlertController animated:YES completion:nil];
}

@end
