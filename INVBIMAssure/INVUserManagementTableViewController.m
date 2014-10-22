//
//  INVUserManagementTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/22/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVUserManagementTableViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 60;
static const NSInteger DEFAULT_NUM_SECTIONS = 3;
static const NSInteger DEFAULT_NUM_ROWS_SECTION = 1;
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


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self fetchListOfAccountMembers];
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
        INVMembership* member = [self.dataResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = member.name;
        cell.detailTextLabel.text = member.email;
    }
    if (indexPath.section == SECTIONINDEX_INVITEDUSERS) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" ];
        cell.textLabel.text = NSLocalizedString(@"INVITED_USERS",nil);
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTIONINDEX_CURRENTUSERS) {
       return NSLocalizedString(@"CURRENT_USERS",nil);
    }
    return nil;
}



#pragma mark - server side
-(void)fetchListOfAccountMembers {
    [self.globalDataManager.invServerClient getMembershipForAccount:self.globalDataManager.loggedInAccount withCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
#pragma note Yes - you could have directly accessed accounts from project manager. Using FetchResultsController directly makes it simpler
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                NSLog(@"%s. %@",__func__,self.dataResultsController.fetchedObjects);
                [self.tableView reloadData];
            }
            else {
#warning - display error
            }
            
        }
        else {
#warning - display error
        }
    }];
}

#pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"ComposeMailSegue"]) {
         if ([MFMailComposeViewController canSendMail]) {
             MFMailComposeViewController* mailVC = segue.destinationViewController;
             [mailVC setToRecipients:@[@"r1_priya@yahoo.com"]];
             [mailVC setSubject:@"test"];
         }
         else {
#warning display error that mail cannot be composed
         }
     }
 }



/* unused*
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
*/
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}
 */
#pragma mark - accessor
-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.accountManager.fetchRequestForAccountMembership managedObjectContext:self.accountManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    }
    return  _dataResultsController;
}

@end
