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
NSString* const KVO_INVOnAccountMenuSelected = @"accountsMenuSelected";
NSString* const KVO_INVOnUserProfileMenuSelected = @"userProfileMenuSelected";
NSString* const KVO_INVOnInfoMenuSelected = @"infoMenuSelected";
NSString* const KVO_INVOnProjectsMenuSelected = @"projectsMenuSelected";
NSString* const KVO_INVOnLogoutMenuSelected = @"logoutMenuSelected";
NSString* const KVO_INVOnManageUsersMenuSelected = @"manageUsersMenuSelected";

#pragma mark - private interface
@interface INVMainMenuViewController ()
@property (nonatomic,assign)BOOL accountsMenuSelected;
@property (nonatomic,assign)BOOL userProfileMenuSelected;
@property (nonatomic,assign)BOOL infoMenuSelected;
@property (nonatomic,assign)BOOL projectsMenuSelected;
@property (nonatomic,assign)BOOL logoutMenuSelected;
@property (nonatomic,assign)BOOL manageUsersMenuSelected;

@property IBOutlet UIButton *accountsButton;
@property IBOutlet UILabel *accountsBadge;

@end

#pragma mark - public implementation
@implementation INVMainMenuViewController {
    INVNotificationPollerDataSource *_notificationDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor* redColor = [UIColor colorWithRed:143.0/255 green:10.0/255 blue:43.0/255 alpha:1.0];
    [self.view setBackgroundColor:redColor];
    
    [self attachToPoller];
    
    self.accountsBadge.hidden = YES;
    
    self.accountsBadge.layer.cornerRadius = 10;
    self.accountsBadge.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.accountsBadge.layer.borderWidth = 2;
    self.accountsBadge.layer.masksToBounds = YES;
}

-(void) awakeFromNib {
}

- (void)didReceiveMemoryWarning {
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

-(void) attachToPoller {
    __block NSArray *_previousInvites = nil;
    
    _notificationDataSource = [INVNotificationPollerDataSource sourceWithBlock:^(void(^callback)(NSArray *)) {
        [self.globalDataManager.invServerClient getPendingInvitationsForSignedInUserWithCompletionBlock:^(INVEmpireMobileError *error) {
            NSArray *invites = [self.globalDataManager.invServerClient.accountManager accountInvitesForUser];
            NSMutableArray *difference = [invites mutableCopy];
            [difference removeObjectsInArray:_previousInvites];
            
            callback(difference);
            
            _previousInvites = invites;
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePendingInvite:)
                                                 name:INVNotificationPoller_DidRecieveNotificationNotification
                                               object:nil];
    
    [[INVNotificationPoller instance] addDataSource:_notificationDataSource];
}

-(void) handlePendingInvite:(NSNotification *) notification {
    if (notification.userInfo[INVNotificationPoller_DataSourceKey] != _notificationDataSource) {
        return;
    }
    
    NSArray *invites = [self.globalDataManager.invServerClient.accountManager accountInvitesForUser];
    
    self.accountsBadge.text = [NSString stringWithFormat:@"%ld", (unsigned long)[invites count]];
    self.accountsBadge.hidden = invites.count <= 0;
}

#pragma mark - UIEvent handlers

- (IBAction)onLogoutViewSelected:(id)sender {
    self.logoutMenuSelected = YES;
}

- (IBAction)onAccountsViewSelected:(id)sender {
    self.accountsMenuSelected = YES;
}

- (IBAction)onUserProfileViewSelected:(id)sender {
    self.userProfileMenuSelected = YES;
}

- (IBAction)onInfoViewSelected:(id)sender {
    self.infoMenuSelected = YES;
}

- (IBAction)onProjectsViewSelected:(id)sender {
    self.projectsMenuSelected = YES;
}

- (IBAction)onManageUsers:(UIButton *)sender {
    self.manageUsersMenuSelected = YES;
}

@end
