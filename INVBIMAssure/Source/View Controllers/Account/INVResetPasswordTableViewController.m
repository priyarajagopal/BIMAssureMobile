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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.emailTextField becomeFirstResponder];
}

- (void)awakeFromNib
{
    self.refreshControl = nil;

    [self updateUI];
}

- (void)setEmail:(NSString *)email
{
    _email = email;

    [self updateUI];
}

- (void)updateUI
{
    self.emailTextField.text = self.email;
}

- (IBAction)resetPassword:(id)sender
{
    // Show a progress hud
    [self.emailTextField resignFirstResponder];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.globalDataManager.invServerClient
        resetPasswordForUserWithEmail:self.emailTextField.text
                  withCompletionBlock:INV_COMPLETION_HANDLER {
                      INV_ALWAYS : {
                          [hud hide:YES];

                          UIAlertController *alertController = [UIAlertController
                              alertControllerWithTitle:NSLocalizedString(@"PASSWORD_RESET_SUCCESS_TITLE", nil)
                                               message:NSLocalizedString(@"PASSWORD_RESET_SUCCESS_MESSAGE", nil)
                                        preferredStyle:UIAlertControllerStyleAlert];

                          [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                              style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction *action) {
                                                                                [self performSegueWithIdentifier:@"unwind"
                                                                                                          sender:nil];
                                                                            }]];

                          [self presentViewController:alertController animated:YES completion:nil];
                      }

                      INV_SUCCESS:
                      INV_ERROR:
                          INVLogError(@"%@", error);
                  }];
}

@end
