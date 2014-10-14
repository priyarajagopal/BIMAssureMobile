//
//  INVMainMenuViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/14/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVMainMenuViewController.h"

#pragma mark - KVO
NSString* const INV_KVO_ONACCOUNTSMENUSELECTED = @"accountsMenuSelected";
NSString* const INV_KVO_ONUSERPROFILEMENUSELECTED = @"userProfileMenuSelected";
NSString* const INV_KVO_ONSETTINGSMENUSELECTED = @"settingsMenuSelected";
NSString* const INV_KVO_ONPROJECTSMENUSELECTED = @"projectsMenuSelected";



#pragma mark - private interface
@interface INVMainMenuViewController ()
@property (nonatomic,assign)BOOL accountsMenuSelected;
@property (nonatomic,assign)BOOL userProfileMenuSelected;
@property (nonatomic,assign)BOOL settingsMenuSelected;
@property (nonatomic,assign)BOOL projectsMenuSelected;

@end

#pragma mark - public implementation
@implementation INVMainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark - UIEvent handlers

- (IBAction)onAccountsViewSelected:(id)sender {
    self.accountsMenuSelected = YES;
}

- (IBAction)onUserProfileViewSelected:(id)sender {
    self.userProfileMenuSelected = YES;
}

- (IBAction)onSettingsViewSelected:(id)sender {
    self.settingsMenuSelected = YES;
}

- (IBAction)onProjectsViewSelected:(id)sender {
    self.projectsMenuSelected = YES;
}
@end
