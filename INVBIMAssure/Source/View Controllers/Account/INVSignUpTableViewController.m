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

const NSInteger DEFAULT_CELL_HEIGHT = 50;
const NSInteger SUBSCRIPTION_CELL_HEIGHT = 207;
const NSInteger DEFAULT_NUM_CELLS = 5;

const NSInteger NUM_SECTIONS = 2;
const NSInteger NUM_ROWS_USERDETAILS = 3;
const NSInteger NUM_ROWS_ACCOUNT     = 2;

const NSInteger SECTIONINDEX_USERDETAILS = 0; // user details
const NSInteger SECTIONINDEX_ACCOUNT     = 1; // subscription info or invitation code as appropriate

const NSInteger CELLINDEX_USERNAME         = 0;
const NSInteger CELLINDEX_EMAIL            = 1;
const NSInteger CELLINDEX_PASSWORD         = 2;

const NSInteger CELLINDEX_SUBSCRIPTIONTYPE = 1;
const NSInteger CELLINDEX_INVITATIONCODE   = 1;
const NSInteger CELLINDEX_TOGGLE           = 0;

@interface INVSignUpTableViewController()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, assign)BOOL invitationCodeAvailable;
@property (nonatomic, weak)  UITextField* userNameTextField;
@property (nonatomic, weak)  UITextField* emailTextField;
@property (nonatomic, weak)  UITextField* passwordTextField;
@property (nonatomic, weak)  UITextField* invitationCodeTextField;
@property (nonatomic, weak)  UISwitch* invitationSwitch;
@property (nonatomic, weak)  INVSubscriptionLevelsTableViewCell* subscriptionCell;


@end

@implementation INVSignUpTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"SIGN_UP", nil);
    self.invitationCodeAvailable = NO;
    
    UINib* userCellNib = [UINib nibWithNibName:@"INVGenericTextEntryTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:userCellNib forCellReuseIdentifier:@"UserCell"];
    
    UINib* invCellNib = [UINib nibWithNibName:@"INVGenericTextEntryTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:invCellNib forCellReuseIdentifier:@"InvitationCodeCell"];

    UINib* subscriptionCellNib = [UINib nibWithNibName:@"INVSubscriptionLevelsTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:subscriptionCellNib forCellReuseIdentifier:@"SubscriptionCell"];

    UINib* switchCellNib = [UINib nibWithNibName:@"INVGenericSwitchTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:switchCellNib forCellReuseIdentifier:@"ToggleCell"];
    
/*
    UIEdgeInsets contentInset = self.tableView.scrollIndicatorInsets;
    contentInset.left =  30;
    contentInset.right = 30;
    self.tableView.contentInset = contentInset;
  */
    
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
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
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTIONINDEX_ACCOUNT) {
        return NUM_ROWS_ACCOUNT;
    }
    else if (section == SECTIONINDEX_USERDETAILS) {
        return NUM_ROWS_USERDETAILS;
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SECTIONINDEX_USERDETAILS) {
        INVGenericTextEntryTableViewCell* cell = (INVGenericTextEntryTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        if (indexPath.row == CELLINDEX_USERNAME) {
            FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:25];
            cell.labelHeading.attributedText = userIcon.attributedString;
            cell.textFieldEntry.placeholder = NSLocalizedString(@"FULL_NAME", nil);
            self.userNameTextField = cell.textFieldEntry;
        }
        if (indexPath.row == CELLINDEX_PASSWORD) {
            FAKFontAwesome *pwdIcon = [FAKFontAwesome keyIconWithSize:25];
            cell.labelHeading.attributedText = pwdIcon.attributedString;
            cell.textFieldEntry.placeholder = NSLocalizedString(@"PASSWORD", nil);
            cell.textFieldEntry.secureTextEntry = YES;
            
            self.passwordTextField = cell.textFieldEntry;
        }
        if (indexPath.row == CELLINDEX_EMAIL) {
            FAKFontAwesome *emailIcon = [FAKFontAwesome envelopeIconWithSize:25];
            cell.labelHeading.attributedText = emailIcon.attributedString;
            cell.textFieldEntry.placeholder = NSLocalizedString(@"EMAIL", nil);
            cell.textFieldEntry.keyboardType = UIKeyboardTypeEmailAddress;
            
            self.emailTextField = cell.textFieldEntry;
            
        }
        cell.textFieldEntry.delegate = self;
        return cell;
        
    }
    
    if (indexPath.section == SECTIONINDEX_ACCOUNT) {
        if (indexPath.row == CELLINDEX_TOGGLE) {
            INVGenericSwitchTableViewCell* cell = (INVGenericSwitchTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:@"ToggleCell"];
            
            self.invitationSwitch = cell.toggleSwitch;
            [self.invitationSwitch addTarget:self action:@selector(onInvitationSwitchToggled:) forControlEvents:UIControlEventValueChanged];
            [self.invitationSwitch setOn:NO];
            cell.toggleLabel.text = NSLocalizedString(@"HAVE_INVITATION_CODE", nil);
            return cell;

        }
        else {
            if (self.invitationCodeAvailable) {
                INVGenericTextEntryTableViewCell* cell = (INVGenericTextEntryTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"InvitationCodeCell"];
                FAKFontAwesome *ckIcon = [FAKFontAwesome checkIconWithSize:25];
                cell.labelHeading.attributedText = ckIcon.attributedString;
                cell.textFieldEntry.placeholder = NSLocalizedString(@"INVITATION_CODE", nil);
                cell.textFieldEntry.delegate = self;
                self.invitationCodeTextField = cell.textFieldEntry;
                
                return cell;
                
            }
            else {
                self.subscriptionCell = (INVSubscriptionLevelsTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"SubscriptionCell"];
                return self.subscriptionCell;
             }
        }
    }
    
    return nil;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.invitationCodeAvailable && indexPath.section == SECTIONINDEX_ACCOUNT && indexPath.row == CELLINDEX_SUBSCRIPTIONTYPE) {
        return SUBSCRIPTION_CELL_HEIGHT;
    }
    return DEFAULT_CELL_HEIGHT;
}

#pragma mark - switch toggled
-(void)onInvitationSwitchToggled:(UISwitch*)sender {
    if (sender == self.invitationSwitch) {
        self.invitationCodeAvailable = self.invitationSwitch.isOn?:NO;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:CELLINDEX_INVITATIONCODE inSection:SECTIONINDEX_ACCOUNT]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        [self.invitationCodeTextField becomeFirstResponder];
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


#pragma mark - server integration


#pragma mark - UIEvent Handlers
- (IBAction)onSignUpTapped:(UIBarButtonItem*)sender {
    NSString* email = self.emailTextField.text;
    NSString* name = self.userNameTextField.text;
    NSString* pass = self.passwordTextField.text;
    if (self.invitationCodeAvailable) {
        NSString* code = self.invitationCodeTextField.text;
        NSLog(@"%@: %@: %@: %@", email,name,pass, code);
        
    }
    else {
        _INV_SUBSCRIPTION_LEVEL subscriptionLevel = self.subscriptionCell.selectedSubscriptionType;
        NSNumber* package = @(subscriptionLevel);
    }
    
    NSLog(@"%@: %@: %@:", email,name,pass);
    
}



@end
