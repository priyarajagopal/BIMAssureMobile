//
//  INVSignUpTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVSignUpTableViewController.h"
#import "INVGenericTextEntryTableViewCell.h"
#import "INVGenericSwitchTableViewCell.h"
#import "INVSubscriptionLevelsTableViewCell.h"
#import "INVTextViewTableViewCell.h"
#import "INVSignUpTableViewConfigDataSource.h"
#import "INVServerConfigManager.h"

NSString *const KVO_INVSignupSuccess = @"signupSuccess";

#define SECTION_BASIC_INFO 0
#define SECTION_USER_INFO 1
#define SECTION_INVITATION_INFO 2
#define SECTION_ACCOUNT_INFO 3

@interface INVSignUpTableViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@property (nonatomic, weak) IBOutlet UITextField *userAddressTextField;
@property (nonatomic, weak) IBOutlet UITextField *userPhoneTextField;
@property (nonatomic, weak) IBOutlet UITextField *userCompanyNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *userCompanyTitleTextField;

@property (nonatomic, weak) IBOutlet UISwitch *invitationSwitch;
@property (nonatomic, weak) IBOutlet UITextField *invitationCodeTextField;

@property (nonatomic, weak) IBOutlet UITextField *accountNameTextField;
@property (nonatomic, weak) IBOutlet UITextView *accountDescriptionTextView;
@property (nonatomic, weak) IBOutlet UITextField *accountCompanyNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountCompanyAddressTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountContactNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountContactPhoneTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountNumberOfEmployeesTextField;

@property (nonatomic, assign) CGFloat acctDescRowHeight;

@end

@implementation INVSignUpTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = NSLocalizedString(@"CREATE_USER_ACCOUNT", nil);
    self.refreshControl = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self textViewDidChange:nil];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.superview.backgroundColor = self.view.backgroundColor;

    [self.view.superview addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.view
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view.superview
                                     attribute:NSLayoutAttributeLeadingMargin
                                    multiplier:1
                                      constant:150],

        [NSLayoutConstraint constraintWithItem:self.view.superview
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeTrailingMargin
                                    multiplier:1
                                      constant:150],

        [NSLayoutConstraint constraintWithItem:self.view
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view.superview
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1
                                      constant:0],

        [NSLayoutConstraint constraintWithItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view.superview
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                      constant:0]
    ]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.invitationSwitch.on) {
        // Hide the final section
        return [super numberOfSectionsInTableView:tableView] - 1;
    }
    else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_INVITATION_INFO && !self.invitationSwitch.on) {
        return [super tableView:tableView numberOfRowsInSection:section] - 1;
    }
    else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_ACCOUNT_INFO && indexPath.row == 1) {
        return self.acctDescRowHeight;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        BOOL isEmail = [self.emailTextField.text isValidEmail];
        if (!isEmail) {
            self.navigationItem.prompt = NSLocalizedString(@"INVALID_EMAIL", nil);

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.navigationItem.prompt = nil;
            });

            return NO;
        }
    }

    return YES;
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

#pragma mark - server side
- (void)signupUserAndCreateDefaultAccount
{
    [self showSignupProgress];

    NSString *pass = self.passwordTextField.text;

    NSError *error = nil;
    NSRegularExpression *expression =
        [NSRegularExpression regularExpressionWithPattern:[[INVServerConfigManager instance] passportPasswordVerificationRegex]
                                                  options:0
                                                    error:&error];

    if (!error) {
        NSArray *matches = [expression matchesInString:pass options:0 range:NSMakeRange(0, pass.length)];
        if (matches.count == 0) {
            [self hideSignupProgress];
            [self showPasswordInvalidAlert];

            return;
        }
    }

    // TODO - Support subscription levels
    // _INV_SUBSCRIPTION_LEVEL subscriptionLevel = self.subscriptionCell.selectedSubscriptionType;
    NSNumber *package = @(0);

    // NOTE: Privacy and EUSA are forced accept until UI is finalized
    [self.globalDataManager.invServerClient
        signUpUserWithFirstName:[self.firstNameTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                       lastName:[self.lastNameTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                    userAddress:[self.userAddressTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                userPhoneNumber:[self.userPhoneTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                userCompanyName:[self.userCompanyNameTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                          title:[self.userCompanyTitleTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                          email:[self.emailTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                       password:[self.passwordTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
             allowNotifications:YES
                    accountName:[self.accountNameTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
             accountDescription:[self.accountDescriptionTextView.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
               subscriptionType:package
                    companyName:[self.accountCompanyNameTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                 companyAddress:[self.accountCompanyAddressTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                    contactName:[self.accountContactNameTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                   contactPhone:[self.accountContactPhoneTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                numberEmployees:@([self.accountNumberOfEmployeesTextField.text intValue])
                  acceptPrivacy:YES
                     acceptEusa:YES
            withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                [self hideSignupProgress];
                if (!error) {
                    INVLogDebug(@"Succesfully signedup user %@ and created account %@", self.firstNameTextField.text,
                        self.accountNameTextField.text);

                    self.globalDataManager.loggedInUser = self.emailTextField.text;
                    self.signupSuccess = YES;
                }
                else {
                    INVLogError(@"%@", error);

                    [self showSignupFailureAlert];
                }
            }];
}

- (void)signUpUser
{
    [self showSignupProgress];

    
    // NOTE: Privacy and EUSA are forced accept until UI is finalized
    [self.globalDataManager.invServerClient
        signUpUserWithFirstName:[self.firstNameTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                       lastName:[self.lastNameTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                    userAddress:[self.userAddressTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                userPhoneNumber:[self.userPhoneTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                userCompanyName:[self.userCompanyNameTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                          title:[self.userCompanyTitleTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                          email:[self.emailTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                       password:[self.passwordTextField.text
                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
             allowNotifications:NO
                  acceptPrivacy:YES
                     acceptEusa:YES
            withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                [self hideSignupProgress];

                if (!error) {
                    INVLogDebug(@"Succesfully signedup user %@ ", self.firstNameTextField.text);

                    self.globalDataManager.loggedInUser = self.emailTextField.text;
                    self.globalDataManager.invitationCodeToAutoAccept = self.invitationCodeTextField.text;
                    self.signupSuccess = YES;
                }
                else {
                    [self showSignupFailureAlert];
                }
            }];
}

#pragma mark -helper
- (void)showSignupProgress
{
    self.hud = [MBProgressHUD signupHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

- (void)hideSignupProgress
{
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:YES];
}

- (NSString *)defaultAccountName
{
    NSString *name = [NSString stringWithFormat:@"%@ %@", self.firstNameTextField.text, self.lastNameTextField.text];

    return [NSString stringWithFormat:NSLocalizedString(@"DEFAULT_ACCOUNT_PREFIX", nil), name];
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

- (void)showPasswordInvalidAlert
{
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"SIGNUP_FAILURE", nil)
                         message:[NSString stringWithFormat:@"Password must be %@",
                                           [[INVServerConfigManager instance] passportPasswordVerificationText]]
                  preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIEvent Handlers

- (IBAction)onInvitationSwitchToggled:(UISwitch *)sender
{
    [self.tableView beginUpdates];

    if (self.invitationSwitch.on) {
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

- (IBAction)onSignUpTapped:(UIBarButtonItem *)sender
{
    if (self.invitationSwitch.on) {
        [self signUpUser];
    }
    else {
        [self signupUserAndCreateDefaultAccount];
    }
}

- (IBAction)textFieldTextChanged:(id)sender
{
    BOOL numberOfEmployeesIsNumber = [[@([self.accountNumberOfEmployeesTextField.text integerValue]) stringValue]
        isEqualToString:self.accountNumberOfEmployeesTextField.text];

    self.signUpButton.enabled =
        ([self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                            .length > 0 &&
                    [self.lastNameTextField.text
                        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                            .length > 0 &&
                    [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                            .length > 0 &&
                    [self.passwordTextField.text
                        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                            .length > 0 &&
                    self.invitationSwitch.on
                ? ([self.invitationCodeTextField.text
                       stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                          .length > 0)
                : ([self.accountNameTextField.text
                       stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                              .length > 0 &&
                      [self.accountCompanyNameTextField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                              .length > 0 &&
                      [self.accountCompanyAddressTextField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                              .length > 0 &&
                      [self.accountContactNameTextField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                              .length > 0 &&
                      [self.accountContactPhoneTextField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                              .length > 0 &&
                      [self.accountNumberOfEmployeesTextField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                              .length > 0 &&
                      numberOfEmployeesIsNumber));
}

#pragma mark - accessors
- (NSString *)signupEmail
{
    return self.emailTextField.text;
}

- (NSString *)signupPassword
{
    return self.passwordTextField.text;
}

- (NSString *)invitationCode
{
    return self.invitationCodeTextField.text;
}

@end
