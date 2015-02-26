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
}

- (void)notificationsEnabledChanged:(id)sender
{
    [[INVNotificationPoller instance] setNotificationsEnabled:self.notificationsEnabledSwitch.isOn];

    [self.globalDataManager.invServerClient
        getSignedInUserProfileWithCompletionBlock:^(INVUser *result, INVEmpireMobileError *error) {
            INV_ALWAYS:
            INV_SUCCESS:
                [self.globalDataManager.invServerClient
                    updateUserProfileInSignedInAccountWithId:nil
                                               withFirstName:result.firstName
                                                    lastName:result.lastName
                                                 userAddress:result.address
                                             userPhoneNumber:result.phoneNumber
                                             userCompanyName:result.companyName
                                                       title:result.title
                                                       email:result.email
                                          allowNotifications:self.notificationsEnabledSwitch.isOn
                                         withCompletionBlock:INV_COMPLETION_HANDLER {
                                             INV_ALWAYS:
                                             INV_SUCCESS:
                                             INV_ERROR:
                                                 INVLogError(@"%@", error);
                                         }];

            INV_ERROR:
                INVLogError(@"%@", error);
        }];
}

@end
