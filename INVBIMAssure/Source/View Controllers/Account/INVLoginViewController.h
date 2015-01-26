//
//  INVLoginViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INVLoginScrollView.h"

#pragma mark - KVO
extern NSString* const KVO_INVLoginSuccess;

@interface INVLoginViewController : INVCustomViewController
@property (strong, nonatomic) IBOutlet INVLoginScrollView *contentScrollView;
@property (nonatomic,readonly) BOOL loginSuccess;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *emailEntryView;
@property (weak, nonatomic) IBOutlet UIView *passwordEntryView;
@property (weak, nonatomic) IBOutlet UIButton *rememberMe;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *emailTextEntry;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *passwordTextEntry;

- (IBAction)onLoginClicked:(id)sender;
- (IBAction)onRememberMeClicked:(id)sender;

@end
