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

@end

@implementation INVUserProfileTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchUserProfileDetails];
}

- (void)fetchUserProfileDetails
{
    [self.globalDataManager.invServerClient
        getSignedInUserProfileWithCompletionBlock:^(INVSignedInUser *signedInUser, INVEmpireMobileError *error) {
            self.firstNameTextField.text = signedInUser.firstName;
            self.lastNameTextField.text = signedInUser.lastName;

            [self.globalDataManager.invServerClient
                getUserProfileInSignedInAccountWithId:signedInUser.userId
                                  withCompletionBlock:^(INVUser *userProfile, INVEmpireMobileError *error) {
                                      if (error) {
                                          INVLogError(@"%@", error);
                                          return;
                                      }
                                      self.emailTextField.text = userProfile.email;
                                      self.addressTextField.text = userProfile.address;
                                      self.phoneNumberTextField.text = userProfile.phoneNumber;
                                      self.companyTextField.text = userProfile.companyName;
                                  }];
        }];
}
@end
