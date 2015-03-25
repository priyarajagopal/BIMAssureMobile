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

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface INVUserProfileTableViewController ()

@property IBOutlet UITextField *emailTextField;
@property IBOutlet UITextField *firstNameTextField;
@property IBOutlet UITextField *lastNameTextField;

@property IBOutlet UITextField *addressTextField;
@property IBOutlet UITextField *phoneNumberTextField;
@property IBOutlet UITextField *companyTextField;
@property IBOutlet UITextField *titleTextField;

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
    id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.globalDataManager.invServerClient
        getUserProfileInSignedUserWithCompletionBlock:^(INVSignedInUser *userProfile, INVEmpireMobileError *error) {
            INV_ALWAYS:
                [hud hide:YES];

            INV_SUCCESS:
                self.firstNameTextField.text = [userProfile firstName];
                self.lastNameTextField.text = [userProfile lastName];
                self.emailTextField.text = [userProfile email];

                self.addressTextField.text = [userProfile address];
                self.phoneNumberTextField.text = [userProfile phoneNumber];
                self.companyTextField.text = [userProfile companyName];
                self.titleTextField.text = [userProfile title];

                [self.userThumbnailImageView
                    setImageWithURLRequest:[self.globalDataManager.invServerClient
                                               requestToGetThumbnailImageForUser:userProfile.userId]
                          placeholderImage:[UIImage imageNamed:@"ImageNotFound"]
                                   success:nil
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       INVLogError(@"Failed to load image for user profile with error %@", error);
                                   }];

            INV_ERROR:
                INVLogError(@"%@", error);
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

    UIAlertController *alertController = [[UIAlertController alloc] initForImageSelectionInFolder:@"User Thumbnails"
                                                                                      withHandler:^(UIImage *image) {
                                                                                          self.userThumbnailImageView.image =
                                                                                              image;
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
        [self.globalDataManager.invServerClient
            updateUserProfileOfUserWithId:self.globalDataManager.invServerClient.accountManager.signedinUser.userId
                            withFirstName:self.firstNameTextField.text
                                 lastName:self.lastNameTextField.text
                              userAddress:self.addressTextField.text
                          userPhoneNumber:self.phoneNumberTextField.text
                          userCompanyName:self.companyTextField.text
                                    title:self.titleTextField.text
                                    email:self.emailTextField.text
                       allowNotifications:NO
                      withCompletionBlock:^(INVSignedInUser *user, INVEmpireMobileError *error) {
                          INV_ALWAYS:
                              [hud hide:YES];

                          INV_SUCCESS:
                              [self performSegueWithIdentifier:@"unwind" sender:nil];

                          INV_ERROR:
                              INVLogError(@"%@", error);

                              UIAlertController *errorController = [[UIAlertController alloc]
                                  initWithErrorMessage:NSLocalizedString(@"GENERIC_EDIT_USERPROFILE_MESSAGE", nil), error.code];

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
                                                initWithErrorMessage:NSLocalizedString(
                                                                         @"GENERIC_EDIT_USERPROFILE_MESSAGE", nil),
                                                error.code];

                                            [self presentViewController:errorController animated:YES completion:nil];
                                    }];
    }
}

@end
