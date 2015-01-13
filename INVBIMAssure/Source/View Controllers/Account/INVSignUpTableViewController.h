//
//  INVSignUpTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

extern NSString* const KVO_INVSignupSuccess ;

@interface INVSignUpTableViewController : INVCustomTableViewController
@property (weak, nonatomic)         IBOutlet UIBarButtonItem *signUpButton;
@property (assign, nonatomic)       BOOL signupSuccess;
@property (copy,readonly,nonatomic) NSString* signupEmail;
@property (copy,readonly,nonatomic) NSString* signupPassword;
@property (copy,readonly,nonatomic) NSString* invitationCode;

- (IBAction)onSignUpTapped:(UIBarButtonItem*)sender;

@end
