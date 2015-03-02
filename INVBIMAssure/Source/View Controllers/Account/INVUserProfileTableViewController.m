//
//  INVUserProfileTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/4/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVUserProfileTableViewController.h"
#import "UIAlertController+INVCustomizations.h"
#import "UIImage+INVCustomizations.h"

@interface INVUserProfileTableViewController ()

@property IBOutlet UITextField *emailTextField;
@property IBOutlet UITextField *firstNameTextField;
@property IBOutlet UITextField *lastNameTextField;

@property IBOutlet UITextField *addressTextField;
@property IBOutlet UITextField *phoneNumberTextField;
@property IBOutlet UITextField *companyTextField;

@property IBOutlet UIImageView *userThumbnailImageView;
@property IBOutlet UIBarButtonItem *saveButtonItem;

@property (nonatomic, assign) BOOL userProfileChanged;
@property (nonatomic, assign) BOOL userThumbnailChanged;

@end

@implementation INVUserProfileTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;
    self.saveButtonItem.enabled = NO;

    [self fetchUserProfileDetails];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)fetchUserProfileDetails
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    const void (^updateUI)(INVUser *) = ^(INVUser *userProfile) {
        self.firstNameTextField.text = [userProfile firstName];
        self.lastNameTextField.text = [userProfile lastName];
        self.emailTextField.text = [userProfile email];

        if ([userProfile respondsToSelector:@selector(address)]) {
            self.addressTextField.text = [userProfile address];
            self.phoneNumberTextField.text = [userProfile phoneNumber];
            self.companyTextField.text = [userProfile companyName];
        }

        [self.globalDataManager.invServerClient getThumbnailImageForUser:userProfile.userId
                                                   withCompletionHandler:^(id result, INVEmpireMobileError *error) {
                                                       if (error) {
                                                           INVLogError(@"%@", error);
                                                           return;
                                                       }

                                                       self.userThumbnailChanged = NO;
                                                       self.userThumbnailImageView.image = [UIImage imageWithData:result];
                                                   }];
    };

    [self.globalDataManager.invServerClient
        getSignedInUserProfileWithCompletionBlock:^(INVSignedInUser *signedInUser, INVEmpireMobileError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];

            if (error) {
                INVLogError(@"%@", error);
                return;
            }

            updateUI((INVUser *) signedInUser);
        }];
}

#pragma mark - IBActions

- (IBAction)textFieldTextChanged:(id)sender
{
    self.userProfileChanged = YES;

    self.saveButtonItem.enabled = YES;
}

- (IBAction)selectThumbnail:(UIGestureRecognizer *)sender
{
    if ([sender state] != UIGestureRecognizerStateRecognized)
        return;

    UIAlertController *alertController = [[UIAlertController alloc] initForImageSelectionWithHandler:^(UIImage *image) {
        self.userThumbnailImageView.image = image;
        self.userThumbnailChanged = YES;
        self.saveButtonItem.enabled = YES;
    }];

    alertController.modalPresentationStyle = UIModalPresentationPopover;

    [self presentViewController:alertController animated:YES completion:nil];

    alertController.popoverPresentationController.sourceView = [sender view];
    alertController.popoverPresentationController.sourceRect = [[sender view] bounds];

    alertController.popoverPresentationController.permittedArrowDirections =
        UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
}

- (IBAction)saveProfile:(id)sender
{
    id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    BOOL shouldDismiss = !(self.userProfileChanged && self.userThumbnailChanged);

    if (self.userProfileChanged) {
        // NOTE: Will this work without a signed in account?
        [self.globalDataManager.invServerClient
            updateUserProfileInSignedInAccountWithId:nil
                                       withFirstName:self.firstNameTextField.text
                                            lastName:self.lastNameTextField.text
                                         userAddress:self.addressTextField.text
                                     userPhoneNumber:self.phoneNumberTextField.text
                                     userCompanyName:self.companyTextField.text
                                               title:nil
                                               email:self.emailTextField.text
                                  allowNotifications:NO
                                 withCompletionBlock:INV_COMPLETION_HANDLER {
                                     INV_ALWAYS:
                                         [hud hide:YES];

                                     INV_SUCCESS:
                                         [self performSegueWithIdentifier:@"unwind" sender:nil];

                                     INV_ERROR:
                                         INVLogError(@"%@", error);

                                         UIAlertController *errorController = [[UIAlertController alloc]
                                             initWithErrorMessage:NSLocalizedString(@"GENERIC_SIGNUP_FAILURE_MESSAGE", nil),
                                             error.code];

                                         [self presentViewController:errorController animated:YES completion:nil];
                                 }];
    }

    if (self.userThumbnailChanged) {
        [self.globalDataManager.invServerClient
            addThumbnailImageForSignedInUserWithThumbnail:[self.userThumbnailImageView.image writeImageToTemporaryFile]
                                    withCompletionHandler:INV_COMPLETION_HANDLER {
                                        INV_ALWAYS:
                                            if (shouldDismiss) {
                                                [hud hide:YES];
                                            }

                                        INV_SUCCESS:
                                            if (shouldDismiss) {
                                                [self performSegueWithIdentifier:@"unwind" sender:nil];
                                            }

                                        INV_ERROR:
                                            INVLogError(@"%@", error);

                                            UIAlertController *errorController = [[UIAlertController alloc]
                                                initWithErrorMessage:NSLocalizedString(@"GENERIC_SIGNUP_FAILURE_MESSAGE", nil),
                                                error.code];

                                            [self presentViewController:errorController animated:YES completion:nil];
                                    }];
    }
}

@end
