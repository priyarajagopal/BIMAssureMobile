//
//  INVCreateAccountViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/9/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCreateAccountViewController.h"

@interface INVCreateAccountViewController ()

@property IBOutlet UISwitch *invitationCodeSwitch;
@property IBOutlet UITextField *invitationCodeTextField;

@property (nonatomic, weak) IBOutlet UITextField *accountNameTextField;
@property (nonatomic, weak) IBOutlet UITextView *accountDescriptionTextView;
@property (nonatomic, weak) IBOutlet UITextField *accountCompanyNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountCompanyAddressTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountContactNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountContactPhoneTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountNumberOfEmployeesTextField;

@end

@implementation INVCreateAccountViewController

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

- (void)createAccountOnly
{
    // [self showSignupProgress];

    NSString *email = self.globalDataManager.loggedInUser;

    // _INV_SUBSCRIPTION_LEVEL subscriptionLevel = self.subscriptionCell.selectedSubscriptionType;
    NSNumber *package = @(0);

#warning TODO: UPdate the view to accept the remaining fields from user and pass it along to server
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
                                    // [self hideSignupProgress];

                                    if (!error) {
                                        INVLogDebug(@"Succesfully created account %@", self.accountNameTextField.text);

                                        // self.signupSuccess = YES;
                                    }
                                    else {
                                        // [self showSignupFailureAlert];
                                    }
                                }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
