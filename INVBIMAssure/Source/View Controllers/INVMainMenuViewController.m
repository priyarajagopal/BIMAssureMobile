//
//  INVMainMenuViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/14/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVMainMenuViewController.h"

#import "INVNotificationPoller.h"

#pragma mark - KVO
NSString *const KVO_INVOnAccountMenuSelected = @"accountsMenuSelected";
NSString *const KVO_INVOnUserProfileMenuSelected = @"userProfileMenuSelected";
NSString *const KVO_INVOnInfoMenuSelected = @"infoMenuSelected";
NSString *const KVO_INVOnProjectsMenuSelected = @"projectsMenuSelected";
NSString *const KVO_INVOnLogoutMenuSelected = @"logoutMenuSelected";
NSString *const KVO_INVOnManageUsersMenuSelected = @"manageUsersMenuSelected";
NSString *const KVO_INVOnNotificationsMenuSelected = @"notificationsMenuSelected";

#pragma mark - private interface
@interface INVMainMenuViewController ()

@property (nonatomic, assign) BOOL accountsMenuSelected;
@property (nonatomic, assign) BOOL userProfileMenuSelected;
@property (nonatomic, assign) BOOL infoMenuSelected;
@property (nonatomic, assign) BOOL projectsMenuSelected;
@property (nonatomic, assign) BOOL logoutMenuSelected;
@property (nonatomic, assign) BOOL manageUsersMenuSelected;
@property (nonatomic, assign) BOOL notificationsMenuSelected;

@property IBOutlet UIButton *notificationsButton;
@property IBOutlet UILabel *notificationsBadgeLabel;

@end

#pragma mark - public implementation
@implementation INVMainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //  UIColor *redColor = [UIColor colorWithRed:143.0 / 255 green:10.0 / 255 blue:43.0 / 255 alpha:1.0];
    UIColor *grayColor = [UIColor colorWithRed:85.0 / 255 green:85.0 / 255 blue:85.0 / 255 alpha:1.0];

    [self.view setBackgroundColor:grayColor];

    [self attachToPoller];

    self.notificationsBadgeLabel.layer.cornerRadius = 15;
    self.notificationsBadgeLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.notificationsBadgeLabel.layer.borderWidth = 2;
    self.notificationsBadgeLabel.layer.masksToBounds = YES;

    // INVSplitViewPassThroughWindow *passthroughWindow = (INVSplitViewPassThroughWindow *) [[UIApplication sharedApplication]
    // keyWindow];
    // passthroughWindow.passthroughViews = @[ self.view ];
}

- (void)awakeFromNib
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)attachToPoller
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePendingInvite:)
                                                 name:INVNotificationPoller_DidRecieveNotificationNotification
                                               object:nil];

    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handlePendingInvite:) userInfo:nil repeats:YES];

    [self handlePendingInvite:nil];
}

- (void)handlePendingInvite:(NSNotification *)notification
{
    NSArray *notifications = [[INVNotificationPoller instance] allNotifications];

    self.notificationsBadgeLabel.hidden = notifications.count == 0;
    self.notificationsBadgeLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long) notifications.count];
}

#pragma mark - UIEvent handlers

- (IBAction)onLogoutViewSelected:(id)sender
{
    self.logoutMenuSelected = YES;
}

- (IBAction)onAccountsViewSelected:(id)sender
{
    self.accountsMenuSelected = YES;
}

- (IBAction)onUserProfileViewSelected:(id)sender
{
    self.userProfileMenuSelected = YES;
}

- (IBAction)onInfoViewSelected:(id)sender
{
    self.infoMenuSelected = YES;
}

- (IBAction)onProjectsViewSelected:(id)sender
{
    self.projectsMenuSelected = YES;
}

- (IBAction)onManageUsers:(UIButton *)sender
{
    self.manageUsersMenuSelected = YES;
}

- (IBAction)onNotificationsTapped:(id)sender
{
    self.notificationsMenuSelected = YES;
}

@end
