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
    
    self.tableView.editing = YES;
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
    self.tableView.delegate = self;
    
    [self fetchListOfInvitedUsers];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tableView.dataSource = nil;
    self.dataSource = nil;
    self.dateFormatter = nil;
    self.accountManager = nil;
    self.dataResultsController = nil;
}

-(void) setupTableFooter {
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

#pragma mark - server side
-(void)fetchListOfInvitedUsers {
    [self showLoadProgress];
    [self.globalDataManager.invServerClient getPendingInvitationsSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        [self.refreshControl endRefreshing];
        if (!error) { 
#pragma note Yes - you could have directly accessed accounts from account manager. Using FetchResultsController directly makes it simpler
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
         
            }
            else {
                UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_LISTOFINVITEDUSERS_LOAD", nil),dbError.code]];
                [self presentViewController:errController animated:YES completion:nil];
            }
            
        }
        else {
            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_LISTOFINVITEDUSERS_LOAD", nil),error.code]];
            [self presentViewController:errController animated:YES completion:nil];
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
            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:NSLocalizedString(@"ERROR_MAILNOTCONFIGURED", nil)];
            [self presentViewController:errController animated:YES completion:^{
                
            }];
        }
    }
}


#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"CANCEL", nil);
}

#pragma mark - helper
-(NSString*)userForId:(NSNumber*)userId {
    INVMembersArray members = self.accountManager.accountMembership;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId==%@",userId];
    NSArray* matches = [members filteredArrayUsingPredicate:predicate];
    if (matches && matches.count) {
        INVAccountMembership* member = matches[0];
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
        
        __weak typeof(self) weakSelf = self;
        
        _dataSource.editable = YES;
        _dataSource.deletionHandler = ^(id cell, INVInvite *cellData, NSIndexPath *indexPath) {
            UIAlertController *confirmDeleteController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_CANCEL_INVITE", nil)
                                                                                             message:NSLocalizedString(@"CONFIRM_CANCEL_INVITE_MESSAGE", nil)
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
            
            [confirmDeleteController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_CANCEL_INVITE_NEGATIVE", nil)
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:nil]];
            
            [confirmDeleteController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_CANCEL_INVITE_POSITIVE", nil)\
                                                                        style:UIAlertActionStyleDestructive
                                                                      handler:^(UIAlertAction *action) {
                                                                          [weakSelf.globalDataManager.invServerClient cancelInviteWithInvitationId:cellData.invitationId withCompletionBlock:^(INVEmpireMobileError *error) {
                                                                              if (error) {
                                                                                  NSLog(@"%@", error);
                                                                                  return;
                                                                              }
                                                                              NSError* dbError;
                                                                              [weakSelf.dataResultsController performFetch:&dbError];
                                                                              if (!dbError) {
                                                                                  [weakSelf.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                                                              }
                                                                              
                                                                             // [weakSelf fetchListOfInvitedUsers];
                                                                          }];
                                                                      }]];
            
            [weakSelf presentViewController:confirmDeleteController animated:YES completion:nil];
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
        NSFetchRequest *fetchRequest = [self.accountManager.fetchRequestForPendingInvitesForAccount copy];
        fetchRequest.sortDescriptors = @[
            [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]
        ];
        
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.accountManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
