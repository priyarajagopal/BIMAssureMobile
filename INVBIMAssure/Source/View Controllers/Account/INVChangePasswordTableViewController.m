//
//  INVChangePasswordTable'ViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/26/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVChangePasswordTableViewController.h"
#import "INVServerConfigManager.h"

#define SECTION_CURRENT_PASSWORD 0
#define SECTION_NEW_PASSWORD 1

@interface INVChangePasswordTableViewController () <UITextFieldDelegate>

@property IBOutlet UIBarButtonItem *changeBarButtonItem;

@property IBOutlet UITextField *currentPasswordTextField;
@property (getter=theNewPasswordTextField) IBOutlet UITextField *newPasswordTextField;
@property IBOutlet UITextField *confirmPasswordTextField;

@property IBOutlet UILabel *passwordErrorMessageTextField;

- (IBAction)checkPasswordsMatch:(id)sender;
- (IBAction)checkPasswordsEmpty:(id)sender;

- (IBAction)onChangePassword:(id)sender;

@end

@implementation INVChangePasswordTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.currentPasswordTextField becomeFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

// Setting our title this way allows us to bypass the auto-capitalization that apple does to headers by default.
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (section == SECTION_CURRENT_PASSWORD) {
        UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *) view;
        headerFooterView.textLabel.text = [NSString
            stringWithFormat:NSLocalizedString(@"ENTER_PASSWORD_FOR_ACCOUNT", nil), self.globalDataManager.loggedInUser];
    }
}

#pragma mark - IBActions

- (void)checkPasswordsMatch:(id)sender
{
    self.passwordErrorMessageTextField.hidden = YES;

    if (self.newPasswordTextField.text.length && self.confirmPasswordTextField.text.length) {
        if (![self.newPasswordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
            self.passwordErrorMessageTextField.text = NSLocalizedString(@"PASSWORDS_NOT_MATCHING", nil);
            self.passwordErrorMessageTextField.hidden = NO;
        }
    }
}

- (void)checkPasswordsEmpty:(id)sender
{
    BOOL passwordsMatch = [self.newPasswordTextField.text isEqualToString:self.confirmPasswordTextField.text];

    self.changeBarButtonItem.enabled = (self.currentPasswordTextField.text.length > 0) &&
                                       (self.newPasswordTextField.text.length > 0) &&
                                       (self.confirmPasswordTextField.text.length > 0) && passwordsMatch;
}

- (void)passwordChangedError:(INVEmpireMobileError *)error
{
    INVLogError(@"%@", error);

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PASSWORD_CHANGE_FAILED_TITLE", nil)
                                            message:NSLocalizedString(@"PASSWORD_CHANGE_FAILED_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
    alertController.modalPresentationStyle = UIModalPresentationCurrentContext;

    [alertController
        addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)passwordChangedSuccess
{
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PASSWORD_CHANGE_SUCCEEDED_TITLE", nil)
                                            message:NSLocalizedString(@"PASSWORD_CHANGE_SUCCEEDED_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
    alertController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LOG_OUT", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self.globalDataManager performLogout];
                                                      }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPasswordInvalidAlert
{
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"PASSWORD_CHANGE_FAILED_TITLE", nil)
                         message:[NSString stringWithFormat:@"Password must be %@",
                                           [[INVServerConfigManager instance] passportPasswordVerificationText]]
                  preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)onChangePassword:(id)sender
{
    // Resign the first responder
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    if (![self.newPasswordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        self.passwordErrorMessageTextField.text = NSLocalizedString(@"PASSWORDS_NOT_MATCHING", nil);
        self.passwordErrorMessageTextField.hidden = NO;
        return;
    }

    NSString *pass = self.newPasswordTextField.text;

    NSError *error = nil;
    NSRegularExpression *expression =
        [NSRegularExpression regularExpressionWithPattern:[[INVServerConfigManager instance] passportPasswordVerificationRegex]
                                                  options:0
                                                    error:&error];

    if (!error) {
        NSArray *matches = [expression matchesInString:pass options:0 range:NSMakeRange(0, pass.length)];
        if (matches.count == 0) {
            [self showPasswordInvalidAlert];

            return;
        }
    }

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PASSWORD_CHANGE_CONFIRM_TITLE", nil)
                                            message:NSLocalizedString(@"PASSWORD_CHANGE_CONFIRM_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController
        addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"PASSWORD_CHANGE_CONFIRM_YES", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          // Actually perform the change
                                                          [self.globalDataManager.invServerClient
                                                              updatePasswordForUserWithEmail:self.globalDataManager.loggedInUser
                                                                          andCurrentPassword:self.currentPasswordTextField.text
                                                                             withNewPassword:self.newPasswordTextField.text
                                                                         withCompletionBlock:^(INVEmpireMobileError *error) {
                                                                             if (error) {
                                                                                 [self passwordChangedError:error];
                                                                             }
                                                                             else {
                                                                                 [self passwordChangedSuccess];
                                                                             }
                                                                         }];
                                                      }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

@end
