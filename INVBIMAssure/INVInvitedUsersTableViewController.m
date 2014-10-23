//
//  INVInvitedUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/22/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVInvitedUsersTableViewController.h"
static const NSInteger DEFAULT_CELL_HEIGHT = 70;
static const NSInteger DEFAULT_NUM_SECTIONS = 1;
static const NSInteger DEFAULT_NUM_ROWS_SECTION = 0;


@interface INVInvitedUsersTableViewController ()
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVAccountManager* accountManager;
@property (nonatomic,strong)NSDateFormatter* dateFormatter;
@end

@implementation INVInvitedUsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"INVITED_USERS", nil);
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
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    [self fetchListOfInvitedUsers];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return DEFAULT_NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataResultsController.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitedUserCell" ];
    INVInvite* invite = [self.dataResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = invite.email;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString (@"INVITED_BY_ON",nil),[self userForId:invite.updatedBy], [self.dateFormatter stringFromDate:invite.updatedAt]];
   
    return cell;
}



#pragma mark - server side
-(void)fetchListOfInvitedUsers {
    [self.globalDataManager.invServerClient getPendingInvitationsSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
#pragma note Yes - you could have directly accessed accounts from account manager. Using FetchResultsController directly makes it simpler
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

#pragma mark - helper
-(NSString*)userForId:(NSNumber*)userId {
    INVMembersArray members = self.accountManager.accountMembership;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId==%@",userId];
    NSArray* matches = [members filteredArrayUsingPredicate:predicate];
    if (matches && matches.count) {
        INVMembership* member = matches[0];
        return member.email;
    }
    return nil;
}

#pragma mark - accessor
-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.accountManager.fetchRequestForPendingInvitesForAccount managedObjectContext:self.accountManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    }
    return  _dataResultsController;
}

-(NSDateFormatter*)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

@end
