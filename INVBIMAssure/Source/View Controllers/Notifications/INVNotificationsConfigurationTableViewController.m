//
//  INVNotificationsConfigurationTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/3/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVNotificationsConfigurationTableViewController.h"
#import "INVNotificationPoller.h"

@interface INVNotificationsConfigurationTableViewController ()

@property IBOutlet UISwitch *notificationsEnabledSwitch;

- (IBAction)notificationsEnabledChanged:(id)sender;

@end

@implementation INVNotificationsConfigurationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.notificationsEnabledSwitch.on = [[INVNotificationPoller instance] notificationsEnabled];

    [self.globalDataManager.invServerClient
        getUserProfileInSignedUserWithCompletionBlock:^(INVSignedInUser *user, INVEmpireMobileError *error) {
            INV_ALWAYS:
            INV_SUCCESS:
            INV_ERROR:
                INVLogError(@"%@", error);
        }];
}

- (void)notificationsEnabledChanged:(id)sender
{
    [[INVNotificationPoller instance] setNotificationsEnabled:self.notificationsEnabledSwitch.isOn];

    INVSignedInUser *user = self.globalDataManager.invServerClient.accountManager.signedinUser;

    [self.globalDataManager.invServerClient
        updateUserProfileOfUserWithId:user.userId
                        withFirstName:user.firstName
                             lastName:user.lastName
                          userAddress:user.address
                      userPhoneNumber:user.phoneNumber
                      userCompanyName:user.companyName
                                title:user.title
                                email:user.email
                   allowNotifications:self.notificationsEnabledSwitch.isOn
                  withCompletionBlock:^(INVSignedInUser *user, INVEmpireMobileError *error) {
                      INV_ALWAYS:
                      INV_SUCCESS:
                      INV_ERROR:
                          INVLogError(@"%@", error);
                  }];
}

@end
