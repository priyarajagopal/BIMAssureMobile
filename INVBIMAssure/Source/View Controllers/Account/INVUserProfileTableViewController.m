//
//  INVUserProfileTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/4/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVUserProfileTableViewController.h"

@interface INVUserProfileTableViewController ()

@property IBOutlet UITextField *emailTextField;
@property IBOutlet UITextField *firstNameTextField;
@property IBOutlet UITextField *lastNameTextField;

@property IBOutlet UITextField *addressTextField;
@property IBOutlet UITextField *phoneNumberTextField;
@property IBOutlet UITextField *companyTextField;

@property IBOutlet UIBarButtonItem *saveButtonItem;

@end

@implementation INVUserProfileTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.userId) {
        self.emailTextField.enabled = NO;
        self.firstNameTextField.enabled = NO;
        self.lastNameTextField.enabled = NO;
        self.addressTextField.enabled = NO;
        self.phoneNumberTextField.enabled = NO;
        self.companyTextField.enabled = NO;

        // Hide the save button
        self.navigationItem.rightBarButtonItem = nil;
    }

    [self fetchUserProfileDetails];
}

- (void)fetchUserProfileDetails
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    const void (^updateUI)(INVUser *) = ^(INVUser *userProfile) {
        self.firstNameTextField.text = [userProfile firstName];
        self.lastNameTextField.text = [userProfile lastName];
        self.emailTextField.text = [userProfile email];

        if ([userProfile respondsToSelector:@selector(address)]) {
            self.addressTextField.text = [userProfile address];
            self.phoneNumberTextField.text = [userProfile phoneNumber];
            self.companyTextField.text = [userProfile companyName];
        }
    };

    if (self.userId) {
        [self.globalDataManager.invServerClient
            getUserProfileInSignedInAccountWithId:self.userId
                              withCompletionBlock:^(INVUser *userProfile, INVEmpireMobileError *error) {
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];

                                  if (error) {
                                      INVLogError(@"%@", error);
                                      return;
                                  }

                                  updateUI(userProfile);
                              }];
    }
    else {
        [self.globalDataManager.invServerClient
            getSignedInUserProfileWithCompletionBlock:^(INVSignedInUser *signedInUser, INVEmpireMobileError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];

                if (error) {
                    INVLogError(@"%@", error);
                    return;
                }

                updateUI((INVUser *) signedInUser);
            }];
    }
}

- (IBAction)saveProfile:(id)sender
{
    id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    // NOTE: Will this work without a signed in account?
    [self.globalDataManager.invServerClient
        updateUserProfileInSignedInAccountWithId:nil
                                   withFirstName:self.firstNameTextField.text
                                        lastName:self.lastNameTextField.text
                                     userAddress:self.addressTextField.text
                                 userPhoneNumber:self.phoneNumberTextField.text
                                 userCompanyName:self.companyTextField.text
                                           title:nil
                                           email:self.emailTextField.text
                              allowNotifications:NO
                             withCompletionBlock:INV_COMPLETION_HANDLER {
                                 INV_ALWAYS:
                                     [hud hide:YES];

                                 INV_SUCCESS:
                                     [self performSegueWithIdentifier:@"unwind" sender:nil];

                                 INV_ERROR:
                                     INVLogError(@"%@", error);

                                     UIAlertController *errorController = [[UIAlertController alloc]
                                         initWithErrorMessage:NSLocalizedString(@"GENERIC_SIGNUP_FAILURE_MESSAGE", nil),
                                         error.code];

                                     [self presentViewController:errorController animated:YES completion:nil];
                             }];
}

@end
