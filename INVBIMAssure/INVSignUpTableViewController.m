//
//  INVSignUpTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVSignUpTableViewController.h"
#import "INVGenericTextEntryTableViewCell.h"

const NSInteger DEFAULT_CELL_HEIGHT = 45;
const NSInteger DEFAULT_NUM_CELLS = 5;

const NSInteger NUM_SECTIONS = 3;
const NSInteger SECTIONINDEX_USERDETAILS = 0; // user details
const NSInteger SECTIONINDEX_ACCOUNT     = 1; // subscription info or invitation code as appropriate
const NSInteger SECTIONINDEX_SIGNUP      = 2; // sign up button

const NSInteger CELLINDEX_USERNAME         = 0;
const NSInteger CELLINDEX_EMAIL            = 1;
const NSInteger CELLINDEX_PASSWORD         = 2;
const NSInteger CELLINDEX_SUBSCRIPTIONTYPE = 0;
const NSInteger CELLINDEX_INVITATIONCODE   = 0;
const NSInteger CELLINDEX_SIGNUPBUTTON     = 0;

@interface INVSignUpTableViewController()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign)BOOL invitationCodeAvailable;
@property (nonatomic, weak)  UITextField* userNameTextField;
@property (nonatomic, weak)  UITextField* emailTextField;
@property (nonatomic, weak)  UITextField* passwordTextField;
@property (nonatomic, weak)  UITextField* userNameTextField;


@end

@implementation INVSignUpTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"SIGN_UP", nil);
    self.invitationCodeAvailable = NO;
    
    UINib* userCellNib = [UINib nibWithNibName:@"INVGeneralTextEntryTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:userCellNib forCellReuseIdentifier:@"UserCell"];

    
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
    return DEFAULT_NUM_CELLS;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SECTIONINDEX_USERDETAILS) {
        INVGenericTextEntryTableViewCell* cell = (INVGenericTextEntryTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        if (indexPath.row == CELLINDEX_USERNAME) {
            cell.labelHeading.text = NSLocalizedString(@"USERNAME", nil);
        }
        
        
    }
  
    return nil;
}



#pragma mark - helpers

@end
