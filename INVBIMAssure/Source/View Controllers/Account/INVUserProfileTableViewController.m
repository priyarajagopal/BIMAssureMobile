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
    const void (^fetchProfile)(NSNumber *) = ^(NSNumber *userId) {
        [self.globalDataManager.invServerClient
            getUserProfileInSignedInAccountWithId:userId
                              withCompletionBlock:^(INVUser *userProfile, INVEmpireMobileError *error) {
                                  if (error) {
                                      INVLogError(@"%@", error);
                                      return;
                                  }

                                  self.firstNameTextField.text = userProfile.firstName;
                                  self.lastNameTextField.text = userProfile.lastName;

                                  self.emailTextField.text = userProfile.email;
                                  self.addressTextField.text = userProfile.address;
                                  self.phoneNumberTextField.text = userProfile.phoneNumber;
                                  self.companyTextField.text = userProfile.companyName;
                              }];
    };

    if (self.userId) {
        fetchProfile(self.userId);
    }
    else {
        [self.globalDataManager.invServerClient
            getSignedInUserProfileWithCompletionBlock:^(INVSignedInUser *signedInUser, INVEmpireMobileError *error) {
                fetchProfile(signedInUser.userId);
            }];
    }
}

@end
