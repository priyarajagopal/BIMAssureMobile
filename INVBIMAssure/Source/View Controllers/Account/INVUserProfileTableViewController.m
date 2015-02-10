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
        getSignedInUserProfileWithCompletionBlock:^(INVSignedInUser *result, INVEmpireMobileError *error) {
            self.emailTextField.text = result.email;
            self.firstNameTextField.text = result.firstName;
            self.lastNameTextField.text = result.lastName;

            [self.globalDataManager.invServerClient
                getUserProfileInSignedInAccountWithId:result.userId
                                  withCompletionBlock:^(INVUser *result, INVEmpireMobileError *error) {
                                      if (error) {
                                          INVLogError(@"%@", error);
                                          return;
                                      }

                                      self.addressTextField.text = result.address;
                                      self.phoneNumberTextField.text = result.phoneNumber;
                                      self.companyTextField.text = result.companyName;
                                  }];
        }];
}
@end
