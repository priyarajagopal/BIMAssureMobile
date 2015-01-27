//
//  INVCurrentUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/26/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCurrentUsersTableViewController.h"

@interface INVCurrentUsersTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *dataResultsController;
@property (nonatomic,strong) INVGenericTableViewDataSource* dataSource;

-(void) showLoadProgress;

@end

@implementation INVCurrentUsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.tableView.editing = YES;
    self.tableView.dataSource = [self dataSource];
    
    [self fetchListOfAccountMembers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onRefreshControlSelected:(id) sender {
    [self fetchListOfAccountMembers];
}

#pragma mark - server side
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"REMOVE", nil);
}

-(void) confirmDeletion:(NSIndexPath *) indexPath {
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
                                                                                                                          NSError* dbError;
                                                                                                                          [self.dataResultsController performFetch:&dbError];
                                                                                                                          if (!dbError) {
                                                                                                                              [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                                                                                                          }
                                                                                                                      }];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(NSFetchedResultsController *) dataResultsController {
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = [[self.globalDataManager.invServerClient.accountManager fetchRequestForAccountMembership] copy];
        
        _dataResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                     managedObjectContext:self.globalDataManager.invServerClient.accountManager.managedObjectContext
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
    }
    
    return _dataResultsController;
}

-(INVGenericTableViewDataSource *) dataSource {
    if (!_dataSource) {
        _dataSource = [[INVGenericTableViewDataSource alloc] initWithFetchedResultsController:self.dataResultsController forTableView:self.tableView];
        
        __weak typeof(self) weakSelf = self;
        
        _dataSource.editableHandler = ^BOOL (INVAccountMembership *member, NSIndexPath *_) {
            return ![member.email isEqual:weakSelf.globalDataManager.loggedInUser];
        };
        
        _dataSource.deletionHandler = ^(UITableViewCell *cell, INVAccountMembership *member, NSIndexPath *indexPath) {
            [weakSelf confirmDeletion:indexPath];
        };
        
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"UserCell" configureBlock: ^(UITableViewCell *cell, INVAccountMembership* member, NSIndexPath* indexPath){
            cell.textLabel.text = member.name;
            cell.detailTextLabel.text = member.email;
        }];
    }
    
    return _dataSource;
}

#pragma mark - helpers
-(void)showLoadProgress {
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];
}

@end
