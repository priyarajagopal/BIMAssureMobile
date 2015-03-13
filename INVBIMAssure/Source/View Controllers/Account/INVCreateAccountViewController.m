//
//  INVCreateAccountViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/9/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCreateAccountViewController.h"
#import "UIImage+INVCustomizations.h"

#define SECTION_INVITATION_INFO 0
#define SECTION_ACCOUNT_THUMBNAIL 1
#define SECTION_ACCOUNT_INFO 2

@interface INVCreateAccountViewController () <UITextViewDelegate>

@property IBOutlet UISwitch *invitationCodeSwitch;
@property IBOutlet UITextField *invitationCodeTextField;

@property (nonatomic, weak) IBOutlet UITextField *accountNameTextField;
@property (nonatomic, weak) IBOutlet UITextView *accountDescriptionTextView;
@property (nonatomic, weak) IBOutlet UITextField *accountCompanyNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountCompanyAddressTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountContactNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountContactPhoneTextField;
@property (nonatomic, weak) IBOutlet UITextField *accountNumberOfEmployeesTextField;

@property (nonatomic, weak) IBOutlet UIImageView *accountThumbnailImageView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *createBarButtonItem;

@property (nonatomic, assign) CGFloat acctDescRowHeight;

@property BOOL accountProfileChanged;
@property BOOL accountThumbnailChanged;

@end

@implementation INVCreateAccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.acctDescRowHeight = 100;
    self.refreshControl = nil;

    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAccountToEdit:(INVAccount *)accountToEdit
{
    _accountToEdit = accountToEdit;

    [self updateUI];
}

- (void)updateUI
{
    if (self.accountToEdit) {
        self.navigationItem.title = NSLocalizedString(@"EDIT_ACCOUNT", nil);
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"SAVE", nil);

        // This trimming should not be really required. Its just that many of the account when user interface allowed "optional"
        // and the nil values that were mapped internally to
        // string with single character (Yeah- not great)
        self.accountNameTextField.text =
            [self.accountToEdit.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.accountDescriptionTextView.text = self.accountToEdit.overview;
        self.accountCompanyNameTextField.text =
            [self.accountToEdit.companyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.accountCompanyAddressTextField.text = [self.accountToEdit.companyAddress
            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.accountContactNameTextField.text =
            [self.accountToEdit.contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.accountContactPhoneTextField.text =
            [self.accountToEdit.contactPhone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.accountNumberOfEmployeesTextField.text = [self.accountToEdit.numberEmployees stringValue];

        self.accountThumbnailImageView.image = nil;
        [self.globalDataManager.invServerClient getThumbnailImageForAccount:self.accountToEdit.accountId
                                                      withCompletionHandler:^(id result, INVEmpireMobileError *error) {
                                                          if (error) {
                                                              INVLogError(@"%@", error);
                                                              self.accountThumbnailImageView.image =
                                                                  [UIImage imageNamed:@"ImageNotFound"];

                                                              return;
                                                          }
                                                          self.accountThumbnailImageView.image = [UIImage imageWithData:result];
                                                      }];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.invitationCodeSwitch.on) {
        // Show only the first section
        return 1;
    }
    else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_INVITATION_INFO && self.accountToEdit) {
        return 0;
    }

    if (section == SECTION_INVITATION_INFO && !self.invitationCodeSwitch.on) {
        return [super tableView:tableView numberOfRowsInSection:section] - 1;
    }
    else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_INVITATION_INFO && self.accountToEdit) {
        return 0;
    }

    if (indexPath.section == SECTION_ACCOUNT_INFO && indexPath.row == 1) {
        return self.acctDescRowHeight;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_INVITATION_INFO && self.accountToEdit) {
        return nil;
    }

    return [super tableView:tableView titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_INVITATION_INFO && self.accountToEdit) {
        return CGFLOAT_MIN;
    }

    return [super tableView:tableView heightForHeaderInSection:section];
}

#pragma mark - Server Side

- (void)createAccountOnly
{
    [self showSignupProgress];

    NSString *email = self.globalDataManager.loggedInUser;

    // _INV_SUBSCRIPTION_LEVEL subscriptionLevel = self.subscriptionCell.selectedSubscriptionType;
    NSNumber *package = @(0);

    [self.globalDataManager.invServerClient
        createAccountForSignedInUserWithAccountName:self.accountNameTextField.text
                                 accountDescription:self.accountDescriptionTextView.text
                                   subscriptionType:package
                                        companyName:self.accountCompanyNameTextField.text
                                     companyAddress:self.accountCompanyAddressTextField.text
                                        contactName:self.accountContactNameTextField.text
                                       contactPhone:self.accountContactPhoneTextField.text
                                    numberEmployees:@([self.accountNumberOfEmployeesTextField.text intValue])
                                       forUserEmail:email
                                withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                    INV_ALWAYS:
                                    INV_SUCCESS : {
                                        INVLogDebug(@"Succesfully created account %@", self.accountNameTextField.text);

                                        [self.globalDataManager.invServerClient
                                                signIntoAccount:[result accountId]
                                            withCompletionBlock:^(INVEmpireMobileError *error) {
                                                self.globalDataManager.loggedInAccount = [result accountId];

                                                [self.globalDataManager.invServerClient
                                                    addThumbnailImageForSignedInAccountWithThumbnail:
                                                        [self.accountThumbnailImageView.image writeImageToTemporaryFile]
                                                                               withCompletionHandler:INV_COMPLETION_HANDLER {
                                                                                   INV_ALWAYS:
                                                                                       [self hideSignupProgress];

                                                                                   INV_SUCCESS:
                                                                                       self.signupSuccess = YES;

                                                                                   INV_ERROR:
                                                                                       INVLogError(@"%@", error);

                                                                                       [self showSignupFailureAlert];
                                                                               }];
                                            }];
                                    }

                                    INV_ERROR:
                                        [self hideSignupProgress];
                                        [self showSignupFailureAlert];
                                }];
}

- (void)updateAccount
{
    [self showUpdateProgress];

    NSNumber *package = @(0);

    BOOL shouldDismiss = !(self.accountProfileChanged && self.accountThumbnailChanged);

    if (self.accountProfileChanged) {
        [self.globalDataManager.invServerClient
            updateAccountDetailsWithAccountId:self.accountToEdit.accountId
                                         name:self.accountNameTextField.text
                           accountDescription:self.accountDescriptionTextView.text
                             subscriptionType:package
                                  companyName:self.accountCompanyNameTextField.text
                               companyAddress:self.accountCompanyAddressTextField.text
                                  contactName:self.accountContactNameTextField.text
                                 contactPhone:self.accountContactPhoneTextField.text
                              numberEmployees:@([self.accountNumberOfEmployeesTextField.text intValue])
                          withCompletionBlock:INV_COMPLETION_HANDLER {
                              INV_ALWAYS:
                                  [self hideUpdatingProgress];

                              INV_SUCCESS:
                                  [self performSegueWithIdentifier:@"unwind" sender:nil];

                              INV_ERROR:
                                  INVLogError(@"%@", error);

                                  [self showUpdatingFailureAlert];
                          }];
    }

    if (self.accountThumbnailChanged) {
        [self.globalDataManager.invServerClient
            addThumbnailImageForSignedInAccountWithThumbnail:[self.accountThumbnailImageView.image writeImageToTemporaryFile]
                                       withCompletionHandler:INV_COMPLETION_HANDLER {
                                           INV_ALWAYS:
                                               if (shouldDismiss) {
                                                   [self hideUpdatingProgress];
                                               }

                                           INV_SUCCESS:
                                               [self.globalDataManager
                                                   addToRecentlyEditedAccountList:self.accountToEdit.accountId];
                                               if (shouldDismiss) {
                                                   [self performSegueWithIdentifier:@"unwind" sender:nil];
                                               }

                                           INV_ERROR:
                                               INVLogError(@"%@", error);

                                               [self showUpdatingFailureAlert];
                                       }];
    }
}

- (void)showSignupProgress
{
    self.hud = [MBProgressHUD signupHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

- (void)showUpdateProgress
{
    self.hud = [MBProgressHUD updatingHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

- (void)hideSignupProgress
{
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
}

- (void)hideUpdatingProgress
{
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
}

- (void)showSignupFailureAlert
{
    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SIGNUP_FAILURE", nil)
                                            message:NSLocalizedString(@"GENERIC_SIGNUP_FAILURE_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showUpdatingFailureAlert
{
    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil
                                            message:NSLocalizedString(@"ACCOUNT_UPDATE_FAILURE_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - IBActions
- (IBAction)selectThumbnail:(UIGestureRecognizer *)sender
{
    if ([sender state] != UIGestureRecognizerStateRecognized)
        return;

    UIAlertController *thumbnailAlertController =
        [[UIAlertController alloc] initForImageSelectionInFolder:@"Account Thumbnails"
                                                     withHandler:^(UIImage *image) {
                                                         self.accountThumbnailChanged = YES;
                                                         self.accountThumbnailImageView.image = image;

                                                         [self textFieldTextChanged:nil];
                                                     }];

    thumbnailAlertController.modalPresentationStyle = UIModalPresentationPopover;

    [self presentViewController:thumbnailAlertController animated:YES completion:nil];

    thumbnailAlertController.popoverPresentationController.sourceView = [sender view];
    thumbnailAlertController.popoverPresentationController.sourceRect = [[sender view] bounds];
    thumbnailAlertController.popoverPresentationController.permittedArrowDirections =
        UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
}

- (IBAction)onInvitationSwitchToggled:(UISwitch *)sender
{
    [self.tableView beginUpdates];

    if (self.invitationCodeSwitch.on) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(SECTION_ACCOUNT_THUMBNAIL, 2)]
                      withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(SECTION_ACCOUNT_THUMBNAIL, 2)]
                      withRowAnimation:UITableViewRowAnimationNone];
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_INVITATION_INFO]
                  withRowAnimation:UITableViewRowAnimationNone];

    [self.tableView endUpdates];

    // Update the status of the sign in button
    [self textFieldTextChanged:nil];
}

- (IBAction)textFieldTextChanged:(id)sender
{
    if (sender) {
        self.accountProfileChanged = YES;
    }

    [self testAndEnableSaveButton];
}

- (IBAction)createAccount:(id)sender
{
    if (self.accountToEdit) {
        [self updateAccount];
    }
    else {
        [self createAccountOnly];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.accountProfileChanged = YES;
    [self testAndEnableSaveButton];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:SECTION_ACCOUNT_INFO];

    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    self.acctDescRowHeight = fmaxf([cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height, 100);

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - helpers
- (void)testAndEnableSaveButton
{
    BOOL numberOfEmployeesIsNumber = [[@([self.accountNumberOfEmployeesTextField.text integerValue]) stringValue]
                                         isEqualToString:self.accountNumberOfEmployeesTextField.text] &&
                                     [self.accountNumberOfEmployeesTextField.text integerValue] > 0;

    self.createBarButtonItem.enabled =
        self.accountNameTextField.text.length > 0 && self.accountDescriptionTextView.text.length > 0 &&
        self.accountCompanyNameTextField.text.length > 0 && self.accountCompanyAddressTextField.text.length > 0 &&
        self.accountContactNameTextField.text.length > 0 && self.accountContactPhoneTextField.text.length > 0 &&
        self.accountNumberOfEmployeesTextField.text.length > 0 && numberOfEmployeesIsNumber;
}

@end
