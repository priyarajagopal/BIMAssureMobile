//
//  INVMainMenuViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/14/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomViewController.h"

#pragma mark - KVO
extern NSString* const KVO_INVOnAccountMenuSelected ;
extern NSString* const KVO_INVOnUserProfileMenuSelected ;
extern NSString* const KVO_INVOnInfoMenuSelected ;
extern NSString* const KVO_INVOnProjectsMenuSelected;
extern NSString* const KVO_INVOnLogoutMenuSelected;
extern NSString* const KVO_INVOnManageUsersMenuSelected;
extern NSString* const KVO_INVOnNotificationsMenuSelected;

@interface INVMainMenuViewController : INVCustomViewController

@property (weak) IBOutlet UIButton *logoutButton;

- (IBAction)onLogoutViewSelected:(id)sender;
- (IBAction)onAccountsViewSelected:(id)sender;
- (IBAction)onUserProfileViewSelected:(id)sender;
- (IBAction)onInfoViewSelected:(id)sender;

- (IBAction)onProjectsViewSelected:(id)sender;
- (IBAction)onManageUsers:(UIButton *)sender;
- (IBAction)onNotificationsTapped:(id)sender;

@end