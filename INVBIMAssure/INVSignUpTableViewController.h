//
//  INVSignUpTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVSignUpTableViewController : INVCustomTableViewController
- (IBAction)onSignUpTapped:(UIBarButtonItem*)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signUpButton;

@end
