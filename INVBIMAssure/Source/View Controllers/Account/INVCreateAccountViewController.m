//
//  INVCreateAccountViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/9/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCreateAccountViewController.h"

#define SECTION_INVITATION_INFO 0
#define SECTION_ACCOUNT_INFO 1

@interface INVCreateAccountViewController () <UITextViewDelegate>

@property IBOutlet UISwitch *invitationCodeSwitch;
@property IBOutlet UITextField *invitationCodeTextField;

@property (nonatomic, weak) IBOutlet UITextField *accountNameTextField;
@property (nonatomic, weak) IBOutlet UITextView *accountDescriptionTextView;
@property (nonatomic, weak) IBOutlet UITextField *accountCompanyNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountCompanyAddressTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountContactNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountContactPhoneTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountNumberOfEmployeesTextField;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *createBarButtonItem;

@property (nonatomic, assign) CGFloat acctDescRowHeight;

@end

@implementation INVCreateAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self textViewDidChange:nil];
    });

    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAccountToEdit:(INVAccount *)accountToEdit
{
    _accountToEdit = accountToEdit;

    [self updateUI];
}

- (void)updateUI
{
    if (self.accountToEdit) {
        self.navigationItem.title = NSLocalizedString(@"EDIT_ACCOUNT", nil);
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"SAVE", nil);
    }

    self.accountNameTextField.text = self.accountToEdit.name;
    self.accountDescriptionTextView.text = self.accountToEdit.overview;
    self.accountCompanyNameTextField.text = self.accountToEdit.companyName;
    self.accountCompanyAddressTextField.text = self.accountToEdit.companyAddress;
    self.accountContactNameTextField.text = self.accountToEdit.contactName;
    self.accountContactPhoneTextField.text = self.accountToEdit.contactPhone;
    self.accountNumberOfEmployeesTextField.text = [self.accountToEdit.numberEmployees stringValue];

    [self textFieldTextChanged:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.invitationCodeSwitch.on) {
        // Hide the final section
        return [super numberOfSectionsInTableView:tableView] - 1;
    }
    else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_INVITATION_INFO && self.accountToEdit) {
        return 0;
    }

    if (section == SECTION_INVITATION_INFO && !self.invitationCodeSwitch.on) {
        return [super tableView:tableView numberOfRowsInSection:section] - 1;
    }
    else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_INVITATION_INFO && self.accountToEdit) {
        return 0;
    }

    if (indexPath.section == SECTION_ACCOUNT_INFO && indexPath.row == 1) {
        return self.acctDescRowHeight;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_INVITATION_INFO && self.accountToEdit) {
        return nil;
    }

    return [super tableView:tableView titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_INVITATION_INFO && self.accountToEdit) {
        return CGFLOAT_MIN;
    }

    return [super tableView:tableView heightForHeaderInSection:section];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:SECTION_ACCOUNT_INFO];

    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    self.acctDescRowHeight = fmaxf([cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height, 100);

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Server Side

- (void)createAccountOnly
{
    [self showSignupProgress];

    NSString *email = self.globalDataManager.loggedInUser;

    // _INV_SUBSCRIPTION_LEVEL subscriptionLevel = self.subscriptionCell.selectedSubscriptionType;
    NSNumber *package = @(0);

    [self.globalDataManager.invServerClient
        createAccountForSignedInUserWithAccountName:self.accountNameTextField.text
                                 accountDescription:self.accountDescriptionTextView.text
                                   subscriptionType:package
                                        companyName:self.accountCompanyNameTextField.text
                                     companyAddress:self.accountCompanyAddressTextField.text
                                        contactName:self.accountContactNameTextField.text
                                       contactPhone:self.accountContactPhoneTextField.text
                                    numberEmployees:@([self.accountNumberOfEmployeesTextField.text intValue])
                                       forUserEmail:email
                                withCompletionBlock:^(INVEmpireMobileError *error) {
                                    [self hideSignupProgress];

                                    if (!error) {
                                        INVLogDebug(@"Succesfully created account %@", self.accountNameTextField.text);

                                        self.signupSuccess = YES;
                                    }
                                    else {
                                        [self showSignupFailureAlert];
                                    }
                                }];
}

- (void)updateAccount
{
    [self showSignupProgress];

    NSNumber *package = @(0);

    [self.globalDataManager.invServerClient
        updateAccountDetailsWithAccountId:self.accountToEdit.accountId
                                     name:self.accountNameTextField.text
                       accountDescription:self.accountDescriptionTextView.text
                         subscriptionType:package
                              companyName:self.accountCompanyNameTextField.text
                           companyAddress:self.accountCompanyAddressTextField.text
                              contactName:self.accountContactNameTextField.text
                             contactPhone:self.accountContactPhoneTextField.text
                          numberEmployees:@([self.accountNumberOfEmployeesTextField.text intValue])
                      withCompletionBlock:INV_COMPLETION_HANDLER {
                          INV_ALWAYS:
                              [self hideSignupProgress];

                          INV_SUCCESS:
                              self.signupSuccess = YES;

                          INV_ERROR:
                              INVLogError(@"%@", error);

                              [self showSignupFailureAlert];
                      }];
}

- (void)showSignupProgress
{
    self.hud = [MBProgressHUD signupHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

- (void)hideSignupProgress
{
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
}

- (void)showSignupFailureAlert
{
    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SIGNUP_FAILURE", nil)
                                            message:NSLocalizedString(@"GENERIC_SIGNUP_FAILURE_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)onInvitationSwitchToggled:(UISwitch *)sender
{
    [self.tableView beginUpdates];

    if (self.invitationCodeSwitch.on) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:SECTION_ACCOUNT_INFO]
                      withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:SECTION_ACCOUNT_INFO]
                      withRowAnimation:UITableViewRowAnimationNone];
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_INVITATION_INFO]
                  withRowAnimation:UITableViewRowAnimationNone];

    [self.tableView endUpdates];

    // Update the status of the sign in button
    [self textFieldTextChanged:nil];
}

- (IBAction)textFieldTextChanged:(id)sender
{
    BOOL numberOfEmployeesIsNumber = [[@([self.accountNumberOfEmployeesTextField.text integerValue]) stringValue]
                                         isEqualToString:self.accountNumberOfEmployeesTextField.text] &&
                                     [self.accountNumberOfEmployeesTextField.text integerValue] > 0;

    self.createBarButtonItem.enabled =
        self.accountNameTextField.text.length > 0 && self.accountDescriptionTextView.text.length > 0 &&
        self.accountCompanyNameTextField.text.length > 0 && self.accountCompanyAddressTextField.text.length > 0 &&
        self.accountContactNameTextField.text.length > 0 && self.accountContactPhoneTextField.text.length > 0 &&
        self.accountNumberOfEmployeesTextField.text.length > 0 && numberOfEmployeesIsNumber;
}

- (IBAction)createAccount:(id)sender
{
    if (self.accountToEdit) {
        [self updateAccount];
    }
    else {
        [self createAccountOnly];
    }
}

@end
