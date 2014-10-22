//
//  INVUserManagementTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/22/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVUserManagementTableViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_NUM_SECTIONS = 3;
static const NSInteger DEFAULT_NUM_ROWS_SECTION = 1;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;
static const NSInteger SECTIONINDEX_CURRENTUSERS = 0;
static const NSInteger SECTIONINDEX_INVITEUSER = 1;
static const NSInteger SECTIONINDEX_INVITEDUSERS = 2;

@interface INVUserManagementTableViewController ()
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVAccountManager* accountManager;
@end

@implementation INVUserManagementTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"USER_MANAGEMENT_ACCOUNT", nil);
    self.accountManager = self.globalDataManager.invServerClient.accountManager;
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return DEFAULT_NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return DEFAULT_NUM_ROWS_SECTION;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell ;
    
    if (indexPath.section == SECTIONINDEX_INVITEUSER) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InviteActionCell" ];
    }
    if (indexPath.section == SECTIONINDEX_CURRENTUSERS) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" ];
        cell.textLabel.text = NSLocalizedString(@"John Doe",nil);
        cell.detailTextLabel.text = NSLocalizedString(@"Invited By ",nil);
    }
    if (indexPath.section == SECTIONINDEX_INVITEDUSERS) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" ];
        cell.textLabel.text = NSLocalizedString(@"CURRENT_USERS",nil);
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString* reuseId = @"HeaderView";
    UITableViewHeaderFooterView* headerView = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:reuseId];
    headerView.frame = CGRectMake (0,0,tableView.frame.size.width, DEFAULT_HEADER_HEIGHT);
    headerView.textLabel.textColor = [UIColor darkTextColor];
    headerView.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    if (section-1 == SECTIONINDEX_CURRENTUSERS) {
        headerView.textLabel.text = NSLocalizedString(@"CURRENT_USERS",nil);
    }
     return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ProjectDetailSegue" sender:self];
}


@end
