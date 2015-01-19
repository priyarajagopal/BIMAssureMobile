//
//  INVUserManagementTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/22/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVUserManagementTableViewController.h"
#import "INVInviteUsersTableViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 60;
static const NSInteger DEFAULT_TABLE_HEADER_HEIGHT = 50;
static const NSInteger DEFAULT_NUM_SECTIONS = 3;
static const NSInteger DEFAULT_NUM_ROWS_SECTION = 1;
static const NSInteger SECTIONINDEX_CURRENTUSERS = 0;
static const NSInteger SECTIONINDEX_INVITEUSER = 1;
static const NSInteger SECTIONINDEX_INVITEDUSERS = 2;


@interface INVUserManagementTableViewController ()
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVAccountManager* accountManager;
@property (nonatomic,weak)INVInviteUsersTableViewController* inviteUsersVC;
@end

@implementation INVUserManagementTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"USER_MANAGEMENT_ACCOUNT", nil);
      self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.tableHeaderView = [self headerViewWithAccountName];
    [self fetchListOfAccountMembers];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.dataResultsController = nil;
    self.accountManager = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return DEFAULT_NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == SECTIONINDEX_CURRENTUSERS) {
        return [self.dataResultsController.fetchedObjects count];
    }
 
    return DEFAULT_NUM_ROWS_SECTION;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell ;
    
    if (indexPath.section == SECTIONINDEX_INVITEUSER) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InviteActionCell" ];
    }
    if (indexPath.section == SECTIONINDEX_CURRENTUSERS) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" ];
        INVAccountMembership* member = [self.dataResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = member.name;
        cell.detailTextLabel.text = member.email;
    }
    if (indexPath.section == SECTIONINDEX_INVITEDUSERS) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" ];
        cell.textLabel.text = NSLocalizedString(@"INVITED_USERS",nil);
    }
    
    return cell;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTIONINDEX_CURRENTUSERS) {
        return YES;
    }
    
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *accountId = self.globalDataManager.loggedInAccount;
    NSNumber *userId = [[self.dataResultsController objectAtIndexPath:indexPath] userId];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER", nil)
                                                                             message:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER_MESSAGE", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER_NEGATIVE", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER_POSITIVE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          [self.globalDataManager.invServerClient removeUserFromSignedInAccountWithUserId:userId
                                                                                                                      withCompletionBlock:^(INVEmpireMobileError *error) {
                                                                                                                          if (error) {
                                                                                                                              NSLog(@"%@", error);
                                                                                                                              return;
                                                                                                                          }
                                                              
                                                                                                                          [self fetchListOfAccountMembers];
                                                                                                                      }];
                                                        }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(UIView*) headerViewWithAccountName {
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0,0, self.tableView.bounds.size.width,DEFAULT_TABLE_HEADER_HEIGHT)];
    UILabel* header = [[UILabel alloc]initWithFrame:CGRectMake(10,0.0, self.tableView.bounds.size.width-20,DEFAULT_TABLE_HEADER_HEIGHT)];
    header.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    header.textAlignment = NSTextAlignmentCenter;
    header.textColor = [ UIColor darkTextColor];
    UIColor* grayColor = [UIColor colorWithRed:214.0/255 green:214.0/255 blue:214.0/255 alpha:1.0];
    headerView.backgroundColor = grayColor;
    header.text = [NSString stringWithFormat:NSLocalizedString(@"ACCOUNT:",nil),[self accountNameForAccountId:self.globalDataManager.loggedInAccount]];
    [headerView addSubview:header];
    return headerView;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTIONINDEX_CURRENTUSERS) {
       return NSLocalizedString(@"CURRENT_USERS",nil);
    }
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor* cyanColor = [UIColor colorWithRed:194.0/255 green:224.0/255 blue:240.0/255 alpha:1.0];
    // Configure the view for the selected state
    UIView *bgColorView = [[UIView alloc] init];
    UIColor * ltBlueColor = cyanColor;
    
    [bgColorView setBackgroundColor:ltBlueColor];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectedBackgroundView:bgColorView];
    return indexPath;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - server side / data model integration
-(void)fetchListOfAccountMembers {
    [self showLoadProgress];
    [self.globalDataManager.invServerClient getMembershipForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        [self.refreshControl endRefreshing];
        if (!error) {
#pragma note Yes - you could have directly accessed accounts from project manager. Using FetchResultsController directly makes it simpler
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            else {
                UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_FETCH_ACCOUNTMEMBERS", nil),dbError.code]];
                [self presentViewController:errController animated:YES completion:^{ }];
            }
            
        }
        else {
            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_FETCH_ACCOUNTMEMBERS", nil),error.code]];
            [self presentViewController:errController animated:YES completion:^{ }];
        }
    }];
}

-(NSString*)accountNameForAccountId:(NSNumber*)accountId {
    INVAccountArray accounts = [self.globalDataManager.invServerClient.accountManager accountsOfSignedInUser];
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"accountId==%@",accountId];
    NSArray* matches = [accounts filteredArrayUsingPredicate:pred];
    if (matches && matches.count) {
        INVAccount* match = matches[0];
        return match.name;
    }
    return nil;
}

#pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"inviteUserSegue"]) {
         if ([segue.destinationViewController isKindOfClass:[INVInviteUsersTableViewController class]]) {
             self.inviteUsersVC = segue.destinationViewController;
             
         }
     }
 }

#pragma mark - helpers
-(void)showLoadProgress {
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];
    
}

#pragma mark - accessor
-(INVAccountManager*)accountManager {
    if (!_accountManager ) {
        _accountManager = self.globalDataManager.invServerClient.accountManager;
    }
    return _accountManager;
}
-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.accountManager.fetchRequestForAccountMembership managedObjectContext:self.accountManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    return  _dataResultsController;
}


#pragma mark 
-(IBAction)done:(UIStoryboardSegue*)segue {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
