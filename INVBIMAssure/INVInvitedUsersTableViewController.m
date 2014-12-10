//
//  INVInvitedUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/22/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVInvitedUsersTableViewController.h"
#import <VENTokenField/VENTokenField.h>

static const NSInteger DEFAULT_CELL_HEIGHT = 70;


@interface INVInvitedUsersTableViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVAccountManager* accountManager;
@property (nonatomic,strong)NSDateFormatter* dateFormatter;
@property (nonatomic,strong)INVGenericTableViewDataSource* dataSource;

@end

@implementation INVInvitedUsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"INVITED_USERS", nil);
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.dataSource = self.dataSource;
    [self fetchListOfInvitedUsers];
}



-(void) setupTableFooter {
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    NSInteger heightOfTableViewCells = numberOfRows * DEFAULT_CELL_HEIGHT;
    
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.tableView.frame) + heightOfTableViewCells, CGRectGetWidth (self.tableView.frame), CGRectGetHeight(self.tableView.frame)-(heightOfTableViewCells + CGRectGetMinY(self.tableView.frame)))];
    self.tableView.tableFooterView = view;
}

#pragma mark - server side
-(void)fetchListOfInvitedUsers {
    [self showLoadProgress];
    [self.globalDataManager.invServerClient getPendingInvitationsSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        [self.refreshControl endRefreshing];
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
    [self setupTableFooter];
  
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



#pragma mark - NSFetchedResultsControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"%s with object %@ atIndexPath:%@ forChangeType:%d newIndexPath:%@",__func__,anObject,indexPath,type,newIndexPath);
}

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
-(INVGenericTableViewDataSource*)dataSource {
    if (!_dataSource) {
        _dataSource = [[INVGenericTableViewDataSource alloc]initWithFetchedResultsController:self.dataResultsController forTableView:self.tableView];
        INV_CellConfigurationBlock cellConfigurationBlock = ^(UITableViewCell *cell,INVInvite* invite,NSIndexPath* indexPath ){
            cell.textLabel.text = invite.email;
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString (@"INVITED_BY_ON",nil),[self userForId:invite.updatedBy], [self.dateFormatter stringFromDate:invite.updatedAt]];
            
        };
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"InvitedUserCell" configureBlock:cellConfigurationBlock];

    }
    return _dataSource;
}

-(INVAccountManager*) accountManager {
    if (!_accountManager) {
        _accountManager = self.globalDataManager.invServerClient.accountManager;
    }
    return _accountManager;
}

-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.accountManager.fetchRequestForPendingInvitesForAccount managedObjectContext:self.accountManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _dataResultsController.delegate = self;
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

#pragma mark - UIRefreshControl
-(void)onRefreshControlSelected:(id)event {
    [self fetchListOfInvitedUsers];
}

#pragma mark - helper
-(void) showLoadProgress {
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

@end
