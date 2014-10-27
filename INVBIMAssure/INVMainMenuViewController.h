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
extern NSString* const KVO_INVOnSettingsMenuSelected ;
extern NSString* const KVO_INVOnProjectsMenuSelected;
extern NSString* const KVO_INVOnLogoutMenuSelected;
extern NSString* const KVO_INVOnManageUsersMenuSelected;

@interface INVMainMenuViewController : INVCustomViewController
- (IBAction)onLogoutViewSelected:(id)sender;
- (IBAction)onAccountsViewSelected:(id)sender;
- (IBAction)onUserProfileViewSelected:(id)sender;
- (IBAction)onSettingsViewSelected:(id)sender;
- (IBAction)onProjectsViewSelected:(id)sender;
- (IBAction)onManageUsers:(UIButton *)sender;
@end 