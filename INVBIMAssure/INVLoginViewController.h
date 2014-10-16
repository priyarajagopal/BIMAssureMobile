//
//  INVLoginViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - KVO
extern NSString* const KVO_INV_LoginSuccess;

@interface INVLoginViewController : INVCustomViewController
@property (nonatomic,readonly) BOOL loginSuccess;

@property (weak, nonatomic) IBOutlet UIView *emailEntryView;
@property (weak, nonatomic) IBOutlet UIView *passwordEntryView;
@property (weak, nonatomic) IBOutlet UIButton *rememberMe;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *emailTextEntry;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *passwordTextEntry;

- (IBAction)onLoginClicked:(id)sender;
- (IBAction)onRememberMeClicked:(id)sender;

@end
