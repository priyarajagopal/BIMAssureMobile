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
}

@end
