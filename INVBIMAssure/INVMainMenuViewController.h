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


@interface INVMainMenuViewController : INVCustomViewController
- (IBAction)onAccountsViewSelected:(id)sender;
- (IBAction)onUserProfileViewSelected:(id)sender;
- (IBAction)onSettingsViewSelected:(id)sender;
- (IBAction)onProjectsViewSelected:(id)sender;
@end
