//
//  INVMainMenuViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/14/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomViewController.h"

#pragma mark - KVO
extern NSString* const INV_KVO_ONACCOUNTSMENUSELECTED ;
extern NSString* const INV_KVO_ONUSERPROFILEMENUSELECTED ;
extern NSString* const INV_KVO_ONSETTINGSMENUSELECTED ;
extern NSString* const INV_KVO_ONPROJECTSMENUSELECTED;


@interface INVMainMenuViewController : INVCustomViewController
- (IBAction)onAccountsViewSelected:(id)sender;
- (IBAction)onUserProfileViewSelected:(id)sender;
- (IBAction)onSettingsViewSelected:(id)sender;
- (IBAction)onProjectsViewSelected:(id)sender;
@end
