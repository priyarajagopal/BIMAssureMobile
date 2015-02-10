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
    INVSignedInUser *user = self.globalDataManager.invServerClient.accountManager.signedinUser;

    self.emailTextField.text = user.email;
    self.firstNameTextField.text = user.firstName;
    self.lastNameTextField.text = user.lastName;

    self.addressTextField.text = user.address;
    self.phoneNumberTextField.text = user.phoneNumber;
    self.companyTextField.text = user.companyName;
}
@end
