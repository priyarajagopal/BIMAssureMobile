//
//  INVSignUpTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVSignUpTableViewController.h"
#import "INVGenericTextEntryTableViewCell.h"
#import "INVGenericSwitchTableViewCell.h"
#import "INVSubscriptionLevelsTableViewCell.h"
#import "INVTextViewTableViewCell.h"
#import "INVSignUpTableViewConfigDataSource.h"
#import "INVServerConfigManager.h"

NSString* const KVO_INVSignupSuccess = @"signupSuccess";

@interface INVSignUpTableViewController()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, INVTextViewTableViewCellDelegate>
@property (nonatomic, assign)BOOL invitationCodeAvailable;
@property (nonatomic, weak)  UITextField* acntNameTextField;
@property (nonatomic, weak)  UITextView*  acntDescTextView;
@property (nonatomic, weak)  UITextField* userNameTextField;
@property (nonatomic, weak)  UITextField* emailTextField;
@property (nonatomic, weak)  UITextField* passwordTextField;
@property (nonatomic, weak)  UITextField* invitationCodeTextField;
@property (nonatomic, weak)  UISwitch* invitationSwitch;
@property (nonatomic, weak)  INVSubscriptionLevelsTableViewCell* subscriptionCell;
@property (nonatomic, strong) UIAlertController* signupFailureAlertController;
@property (nonatomic, assign) NSInteger descRowHeight;
@property (nonatomic, strong) INVSignUpTableViewConfigDataSource* dataSource;

@end

@implementation INVSignUpTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"CREATE_USER_ACCOUNT", nil);
    self.invitationCodeAvailable = NO;
    
    UINib* userCellNib = [UINib nibWithNibName:@"INVGenericTextEntryTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:userCellNib forCellReuseIdentifier:@"UserCell"];
    
    UINib* acntCellNib = [UINib nibWithNibName:@"INVGenericTextEntryTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:acntCellNib forCellReuseIdentifier:@"AccountNameCell"];
    
    UINib* descCellNib = [UINib nibWithNibName:@"INVTextViewTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:descCellNib forCellReuseIdentifier:@"AccountDescCell"];
    
    UINib* invCellNib = [UINib nibWithNibName:@"INVGenericTextEntryTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:invCellNib forCellReuseIdentifier:@"InvitationCodeCell"];

    UINib* subscriptionCellNib = [UINib nibWithNibName:@"INVSubscriptionLevelsTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:subscriptionCellNib forCellReuseIdentifier:@"SubscriptionCell"];

    UINib* switchCellNib = [UINib nibWithNibName:@"INVGenericSwitchTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:switchCellNib forCellReuseIdentifier:@"ToggleCell"];
    
    self.dataSource = [[INVSignUpTableViewConfigDataSource alloc]initWithSignUpSetting:self.shouldSignUpUser];

    self.tableView.estimatedRowHeight = self.dataSource.estimatedRowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
     self.refreshControl = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.dataSource = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  [self.dataSource numSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    _INVSignUpTableSectionType sectionType = [self.dataSource typeOfSectionAtIndex:section];
    return  [self.dataSource numRowsForSectionType:sectionType withInvitationCodeSet:self.invitationCodeAvailable];

}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _INVSignUpTableSectionType sectionType =  [self.dataSource typeOfSectionAtIndex:indexPath.section];
    _INVSignUpTableRowType rowType = [self.dataSource typeOfRowForSection:sectionType AtIndex:indexPath.row];
    
    if (sectionType == _INVSignUpTableSectionType_UserDetails) {
        INVGenericTextEntryTableViewCell* cell = (INVGenericTextEntryTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        if (rowType == _INVSignUpTableRowType_UserName) {
            FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:25];
            cell.labelHeading.attributedText = userIcon.attributedString;
            cell.textFieldEntry.placeholder = NSLocalizedString(@"FULL_NAME", nil);
            self.userNameTextField = cell.textFieldEntry;
        }
        if (rowType == _INVSignUpTableRowType_Password) {
            FAKFontAwesome *pwdIcon = [FAKFontAwesome keyIconWithSize:25];
            cell.labelHeading.attributedText = pwdIcon.attributedString;
            cell.textFieldEntry.placeholder = NSLocalizedString(@"PASSWORD", nil);
            cell.textFieldEntry.secureTextEntry = YES;
            
            self.passwordTextField = cell.textFieldEntry;
        }
        if (rowType == _INVSignUpTableRowType_Email) {
            FAKFontAwesome *emailIcon = [FAKFontAwesome envelopeIconWithSize:25];
            cell.labelHeading.attributedText = emailIcon.attributedString;
            cell.textFieldEntry.placeholder = NSLocalizedString(@"EMAIL", nil);
            cell.textFieldEntry.keyboardType = UIKeyboardTypeEmailAddress;
            
            self.emailTextField = cell.textFieldEntry;
            
        }
        cell.textFieldEntry.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    if (sectionType == _INVSignUpTableSectionType_ToggleSwitch) {
        INVGenericSwitchTableViewCell* cell = (INVGenericSwitchTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:@"ToggleCell"];
        
        self.invitationSwitch = cell.toggleSwitch;
        [self.invitationSwitch addTarget:self action:@selector(onInvitationSwitchToggled:) forControlEvents:UIControlEventValueChanged];
        [self.invitationSwitch setOn:self.invitationCodeAvailable];
        cell.toggleLabel.text = NSLocalizedString(@"HAVE_INVITATION_CODE", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
 
    }
    if (sectionType == _INVSignUpTableSectionType_Account) {
     
        if (self.invitationCodeAvailable) {
            INVGenericTextEntryTableViewCell* cell = (INVGenericTextEntryTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"InvitationCodeCell"];
            FAKFontAwesome *ckIcon = [FAKFontAwesome checkIconWithSize:25];
            cell.labelHeading.attributedText = ckIcon.attributedString;
            cell.textFieldEntry.placeholder = NSLocalizedString(@"INVITATION_CODE", nil);
            cell.textFieldEntry.delegate = self;
            self.invitationCodeTextField = cell.textFieldEntry;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        }
        else {
            if (rowType == _INVSignUpTableRowType_AccountName) {
                INVGenericTextEntryTableViewCell* cell = (INVGenericTextEntryTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"AccountNameCell"];
                FAKFontAwesome *ckIcon = [FAKFontAwesome gearIconWithSize:25];
                cell.labelHeading.attributedText = ckIcon.attributedString;
                cell.textFieldEntry.placeholder = NSLocalizedString(@"ACCOUNT_NAME", nil);
                cell.textFieldEntry.delegate = self;
                self.acntNameTextField = cell.textFieldEntry;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
                
            }
            if (rowType == _INVSignUpTableRowType_AccountDesc) {
                INVTextViewTableViewCell* cell = (INVTextViewTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"AccountDescCell"];
                self.acntDescTextView = cell.textView;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellDelegate = self;
                return cell;
                
            }
            if (rowType == _INVSignUpTableRowType_Subscription) {
                self.subscriptionCell = (INVSubscriptionLevelsTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"SubscriptionCell"];
                self.subscriptionCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return self.subscriptionCell;
            }
        }
        
    }
    
    return nil;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    _INVSignUpTableSectionType sectionType =  [self.dataSource typeOfSectionAtIndex:indexPath.section];
    return [self.dataSource heightOfRowAtIndex:indexPath.row forSectionType:sectionType withInvitationCodeSet:self.invitationCodeAvailable];

}

#pragma mark - switch toggled
-(void)onInvitationSwitchToggled:(UISwitch*)sender {
    if (sender == self.invitationSwitch) {
        self.invitationCodeAvailable = self.invitationSwitch.isOn?:NO;
        NSInteger section = [self.dataSource indexOfSection:_INVSignUpTableSectionType_Account];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
     }
 }

#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
  
    if (textField == self.userNameTextField) {
        [self.emailTextField becomeFirstResponder];
    }
    else if (textField == self.emailTextField) {
        BOOL isEmail = [self.emailTextField.text isValidEmail];
        if (!isEmail) {
            self.navigationItem.prompt = NSLocalizedString(@"INVALID_EMAIL", nil);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.navigationItem.prompt = nil;
            });
            return NO;
        }
        else {
            [self.passwordTextField becomeFirstResponder];
        }
    }
    else if (textField == self.passwordTextField) {
        if (self.invitationCodeAvailable) {
            [self.invitationCodeTextField becomeFirstResponder];
        }
        else {
            [self.acntNameTextField becomeFirstResponder];
        }
    }
    else if (textField == self.acntNameTextField) {
        [self.acntDescTextView becomeFirstResponder];
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger length = textField.text.length - range.length + string.length;
    
    if (length > 0  ) {
        self.signUpButton.enabled = YES;
    } else {
        self.signUpButton.enabled = NO;
    }
    return YES;
}



#pragma mark - server side
-(void)signupUserAndCreateDefaultAccount {
    [self showSignupProgress];
    
    NSString* email = self.emailTextField.text;
    NSString* name  = self.userNameTextField.text;
    NSString* pass  = self.passwordTextField.text;
    
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:[[INVServerConfigManager instance] passportPasswordVerificationRegex]
                                                                                options:0
                                                                                  error:&error];
    
    if (!error) {
        NSArray *matches = [expression matchesInString:pass options:0 range:NSMakeRange(0, pass.length)];
        if (matches.count == 0) {
            [self hideSignupProgress];
            
            [self showPasswordInvalidAlert];
        }
    }
    
    _INV_SUBSCRIPTION_LEVEL subscriptionLevel = self.subscriptionCell.selectedSubscriptionType;
    NSNumber* package     = @(subscriptionLevel);
    NSString* accountName = self.acntNameTextField.text;
    NSString* acntDesc    = self.acntDescTextView.text;
    
    [self.globalDataManager.invServerClient signUpUserWithName:name andEmail:email andPassword:pass withAccountName:accountName accountDescription:acntDesc subscriptionType:package withCompletionBlock:^(INVEmpireMobileError *error) {
        [self hideSignupProgress];
        if (!error) {
            NSLog(@"Succesfully signedup user %@ and created account %@",name,accountName);
            self.signupSuccess = YES;
        }
        else {
            [self showSignupFailureAlert];
            
        }
    }];
    
}

-(void)signUpUser {
    [self showSignupProgress ];
    
    NSString* email = self.emailTextField.text;
    NSString* name = self.userNameTextField.text;
    NSString* pass = self.passwordTextField.text;
    [self.globalDataManager.invServerClient signUpUserWithName:name email:email password:pass withCompletionBlock:^(INVEmpireMobileError *error) {
        [self hideSignupProgress];
        if (!error) {
            NSLog(@"Succesfully signedup user %@ ",name);
            self.globalDataManager.invitationCodeToAutoAccept = self.invitationCodeTextField.text;
            self.signupSuccess = YES;
        }
        else {
            [self showSignupFailureAlert];
            
        }
    }];
    
}

-(void)createAccountOnly {
    [self showSignupProgress ];
    
    NSString* email = self.globalDataManager.loggedInUser;
    _INV_SUBSCRIPTION_LEVEL subscriptionLevel = self.subscriptionCell.selectedSubscriptionType;
    NSNumber* package     = @(subscriptionLevel);
    NSString* accountName = self.acntNameTextField.text;
    NSString* acntDesc    = self.acntDescTextView.text;
    
    [self.globalDataManager.invServerClient  createAccountForSignedInUserWithAccountName:accountName accountDescription:acntDesc subscriptionType:package forUserEmail:email withCompletionBlock:^(INVEmpireMobileError *error) {
        [self hideSignupProgress];
        if (!error) {
            NSLog(@"Succesfully created account  %@ ",accountName);
            self.signupSuccess = YES;
        }
        else {
            [self showSignupFailureAlert];
            
        }
    }];
    
}

#pragma mark -helper
-(void)showSignupProgress {
    self.hud = [MBProgressHUD signupHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

-(void)hideSignupProgress {
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
}

-(NSString*) defaultAccountName {
    NSString* name = self.userNameTextField.text;
 
    return [NSString stringWithFormat:NSLocalizedString(@"DEFAULT_ACCOUNT_PREFIX", nil),name ];
}

-(void)showSignupFailureAlert {
    UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.signupFailureAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    self.signupFailureAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SIGNUP_FAILURE", nil) message:NSLocalizedString(@"GENERIC_SIGNUP_FAILURE_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
    [self.signupFailureAlertController addAction:action];
    [self presentViewController:self.signupFailureAlertController animated:YES completion:^{
        
    }];
}
     

-(void) showPasswordInvalidAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SIGNUP_FAILURE", nil)
                                                                             message:[NSString stringWithFormat:@"Password must be %@", [[INVServerConfigManager instance] passportPasswordVerificationText]]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - INVTextViewTableViewCellDelegate
-(void)cellSizeChanged:(CGSize)size withTextString:(NSString*)textStr {
    [self.tableView beginUpdates];
    self.descRowHeight = size.height;
    [self.tableView endUpdates];
}

#pragma mark - UIEvent Handlers
- (IBAction)onSignUpTapped:(UIBarButtonItem*)sender {
    if (self.shouldSignUpUser) {
        if (self.invitationCodeAvailable) {
            [self signUpUser];
        }
        else {
            [self signupUserAndCreateDefaultAccount];
        }
    }
    else {
        [self createAccountOnly];
    }
}

#pragma mark - accessors
-(NSString*)signupEmail {
    return self.emailTextField.text;
}

-(NSString*)signupPassword {
    return self.passwordTextField.text;
}


-(NSString*)invitationCode {
    return self.invitationCodeTextField.text;
}

@end
