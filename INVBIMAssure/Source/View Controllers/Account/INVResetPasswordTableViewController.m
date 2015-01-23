//
//  INVResetPasswordTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/23/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVResetPasswordTableViewController.h"

@interface INVResetPasswordTableViewController ()

@property IBOutlet UITextField *emailTextField;

@end

@implementation INVResetPasswordTableViewController

-(void) viewDidAppear:(BOOL)animated {
    [self.emailTextField becomeFirstResponder];
}

-(void) awakeFromNib {
    self.refreshControl = nil;
    
    [self updateUI];
}

-(void) setEmail:(NSString *)email {
    _email = email;
    
    [self updateUI];
}

-(void) updateUI {
    self.emailTextField.text = self.email;
}

-(IBAction) resetPassword:(id)sender {
    // Show a progress hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self performSegueWithIdentifier:@"unwind" sender:nil];
    });
}

@end
