//
//  INVCurrentUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/26/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCurrentUsersTableViewController.h"



@interface INVCurrentUsersTableViewController () <NSFetchedResultsControllerDelegate>

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
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }
    [self.globalDataManager.invServerClient getMembershipForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
        else {
            [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
        }
        

        if (!error) {
           [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
        }
        else {
            UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_FETCH_ACCOUNTMEMBERS", nil),error.code]];
            [self presentViewController:errController animated:YES completion:nil];
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
                                                                                                                    INVLogError(@"%@", error);
                                                                                                                    return;
                                                                                                                }
                                                                                                                    
                                                                    }];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(NSFetchedResultsController *) dataResultsController {
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = [self.globalDataManager.invServerClient.accountManager fetchRequestForAccountMembership];
        
        _dataResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                     managedObjectContext:self.globalDataManager.invServerClient.accountManager.managedObjectContext
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
        _dataResultsController.delegate = self;
        NSError* dbError;
        [_dataResultsController performFetch:&dbError];
        
        if (dbError) {
            _dataResultsController = nil;
        }

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


#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

     [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            INVLogWarning(@"Received Unsupported change object type %u", type);
            break;
    }
    
}

#pragma mark - helpers
-(void)showLoadProgress {
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];
}

@end
