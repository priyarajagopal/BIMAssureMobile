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

const NSInteger DEFAULT_CELL_HEIGHT = 50;
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

@interface INVSignUpTableViewController()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign)BOOL invitationCodeAvailable;
@property (nonatomic, weak)  UITextField* userNameTextField;
@property (nonatomic, weak)  UITextField* emailTextField;
@property (nonatomic, weak)  UITextField* passwordTextField;
;


@end

@implementation INVSignUpTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"SIGN_UP", nil);
    self.invitationCodeAvailable = NO;
    
    UINib* userCellNib = [UINib nibWithNibName:@"INVGenericTextEntryTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:userCellNib forCellReuseIdentifier:@"UserCell"];
    
    UINib* switchCellNib = [UINib nibWithNibName:@"INVGenericSwitchTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:switchCellNib forCellReuseIdentifier:@"ToggleCell"];


    
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
            cell.labelHeading.text = NSLocalizedString(@"USERNAME", nil);
            self.userNameTextField = cell.textFieldEntry;
        }
        if (indexPath.row == CELLINDEX_PASSWORD) {
            cell.labelHeading.text = NSLocalizedString(@"PASSWORD", nil);
            self.passwordTextField = cell.textFieldEntry;
        }
        if (indexPath.row == CELLINDEX_EMAIL) {
            cell.labelHeading.text = NSLocalizedString(@"EMAIL", nil);
            self.emailTextField = cell.textFieldEntry;
        }
        return cell;
        
    }
    
    if (indexPath.section == SECTIONINDEX_ACCOUNT) {
        if (indexPath.row == CELLINDEX_TOGGLE) {
            INVGenericSwitchTableViewCell* cell = (INVGenericSwitchTableViewCell*) [self.tableView dequeueReusableCellWithIdentifier:@"ToggleCell"];
            
            self.invitationSwitch = cell.toggleSwitch;
            [self.invitationSwitch addTarget:self action:@selector(onInvitationSwitchToggled:) forControlEvents:UIControlEventValueChanged];
            
            cell.toggleLabel.text = NSLocalizedString(@"HAVE_INVITATION_CODE", nil);
            return cell;

        }
        else {
            UITableViewCell* cell ;
            if (self.invitationSwitch.isOn) {
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"InvitationCodeCell"];
                cell.textLabel.text = NSLocalizedString(@"HAVE_INVITATION_CODE", nil);
            }
            else {
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"SubscriptionCell"];
                cell.textLabel.text = NSLocalizedString(@"PICK_PACKAGE", nil);
            }
            return cell;
            
        }
        
    }
    
  
    return nil;
}

#pragma mark - switch toggled
-(void)onInvitationSwitchToggled:(UISwitch*)sender {
    if (sender == self.invitationSwitch) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:CELLINDEX_INVITATIONCODE inSection:SECTIONINDEX_ACCOUNT]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - helpers

@end
