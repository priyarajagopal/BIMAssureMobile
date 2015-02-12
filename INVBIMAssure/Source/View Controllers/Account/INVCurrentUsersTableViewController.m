//
//  INVCurrentUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/26/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCurrentUsersTableViewController.h"
#import "UIView+INVCustomizations.h"
#import "INVUserProfileTableViewController.h"
#import "INVCurrentUsersProfileTableViewCell.h"
#import "INVBlockUtils.h"

#define SECTION_CURRENT_USER @(-1)

@interface INVCurrentUsersTableViewController ()

@property IBOutlet INVTransitionToStoryboard *userProfileTransition;

@property (nonatomic, strong) NSFetchedResultsController *dataResultsController;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, strong) INVSignedInUser *signedInUser;

@property (nonatomic, strong) NSMutableDictionary *expanded;
@property (nonatomic, strong) NSMutableDictionary *cachedUsers;

@property (nonatomic, strong) NSMutableDictionary *sections;
@property (readonly, nonatomic) NSArray *sortedSections;

- (void)showLoadProgress;

@end

@implementation INVCurrentUsersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.tableView.editing = YES;

    self.expanded = [NSMutableDictionary new];
    self.cachedUsers = [NSMutableDictionary new];
    self.sections = [NSMutableDictionary new];

    UINib *userCellNib = [UINib nibWithNibName:@"INVCurrentUsersProfileTableViewCell" bundle:nil];
    [self.tableView registerNib:userCellNib forCellReuseIdentifier:@"UserCell"];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;

    [self fetchListOfAccountMembers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRefreshControlSelected:(id)sender
{
    [self fetchListOfAccountMembers];
}

- (NSArray *)sortedSections
{
    return [[[self.sections allKeys]
        filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [self.sections[evaluatedObject] count] > 0;
        }]] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isEqual:SECTION_CURRENT_USER])
            return NSOrderedAscending;

        if ([obj2 isEqual:SECTION_CURRENT_USER])
            return NSOrderedDescending;

        return -[obj1 compare:obj2];
    }];
}

#pragma mark - server side
- (void)fetchListOfAccountMembers
{
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }

    [self.globalDataManager.invServerClient getMembershipForSignedInAccountWithCompletionBlock:INV_COMPLETION_HANDLER {
        INV_ALWAYS:
            [self.refreshControl endRefreshing];
            [self.hud hide:YES];

        INV_SUCCESS : {
            [self.dataResultsController performFetch:NULL];
            [self.sections removeAllObjects];

            NSArray *objects = [self.dataResultsController.sections.firstObject objects];
            id successBlock = [INVBlockUtils blockForExecutingBlock:^{
                [self.tableView reloadData];
            } afterNumberOfCalls:objects.count];

            [objects enumerateObjectsUsingBlock:^(INVAccountMembership *membership, NSUInteger idx, BOOL *stop) {
                for (NSNumber *role in membership.roles) {
                    if (self.sections[role] == nil) {
                        self.sections[role] = [NSMutableArray new];
                    }

                    [self.sections[role] addObject:membership];
                }

                [self.globalDataManager.invServerClient
                    getUserProfileInSignedInAccountWithId:membership.userId
                                      withCompletionBlock:^(INVUser *user, INVEmpireMobileError *error) {
                                          self.cachedUsers[user.userId] = user;

                                          if ([user.email isEqual:self.globalDataManager.loggedInUser]) {
                                              self.sections[SECTION_CURRENT_USER] = @[ membership ];
                                          }

                                          [successBlock invoke];
                                      }];
            }];
        }

        INV_ERROR : {
            UIAlertController *errController = [[UIAlertController alloc]
                initWithErrorMessage:NSLocalizedString(@"ERROR_FETCH_ACCOUNTMEMBERS", nil), error.code];
            [self presentViewController:errController animated:YES completion:nil];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSNumber *membershipTypeForSection = self.sortedSections[section];
    NSString *title = INVEmpireMobileClient.membershipRoles[membershipTypeForSection];

    if ([membershipTypeForSection isEqual:SECTION_CURRENT_USER]) {
        title = @"INV_MEMBERSHIP_TYPE_CURRENT_USER";
    }

    return NSLocalizedString(title, nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sortedSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[self.sortedSections[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVCurrentUsersProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    INVAccountMembership *member = [self.sections[self.sortedSections[indexPath.section]] objectAtIndex:indexPath.row];

    cell.user = self.cachedUsers[member.userId];
    cell.expanded = [self.expanded[indexPath] boolValue];

    if (cell.user == nil) {
        [self.globalDataManager.invServerClient
            getUserProfileInSignedInAccountWithId:member.userId
                              withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                  self.cachedUsers[member.userId] = result;
                                  cell.user = result;

                                  [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                                                        withRowAnimation:UITableViewRowAnimationNone];
                              }];
    }

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVAccountMembership *member = [self.sections[self.sortedSections[indexPath.section]] objectAtIndex:indexPath.row];

    if (self.cachedUsers[member.userId]) {
        if ([[self.cachedUsers[member.userId] email] isEqual:self.globalDataManager.loggedInUser]) {
            return UITableViewCellEditingStyleNone;
        }

        return UITableViewCellEditingStyleDelete;
    }

    return UITableViewCellEditingStyleNone;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView beginUpdates];

    INVCurrentUsersProfileTableViewCell *profileCell =
        (INVCurrentUsersProfileTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    self.expanded[indexPath] = @(![self.expanded[indexPath] boolValue]);

    profileCell.expanded = [self.expanded[indexPath] boolValue];

    [tableView endUpdates];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"REMOVE", nil);
}

- (void)confirmDeletion:(NSIndexPath *)indexPath
{
    NSNumber *userId = [[self.dataResultsController objectAtIndexPath:indexPath] userId];

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER", nil)
                                            message:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER_NEGATIVE", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_DELETE_ACCOUNT_MEMBER_POSITIVE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          [self.globalDataManager.invServerClient
                                                              removeUserFromSignedInAccountWithUserId:userId
                                                                                  withCompletionBlock:INV_COMPLETION_HANDLER {
                                                                                      INV_ALWAYS:
                                                                                      INV_SUCCESS:
                                                                                      INV_ERROR:
                                                                                          INVLogError(@"%@", error);
                                                                                  }];
                                                      }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSFetchedResultsController *)dataResultsController
{
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = [self.globalDataManager.invServerClient.accountManager fetchRequestForAccountMembership];

        _dataResultsController = [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.globalDataManager.invServerClient.accountManager.managedObjectContext
              sectionNameKeyPath:nil
                       cacheName:nil];

        NSError *dbError;
        [_dataResultsController performFetch:&dbError];

        if (dbError) {
            _dataResultsController = nil;
        }
    }

    return _dataResultsController;
}

- (INVGenericTableViewDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[INVGenericTableViewDataSource alloc] initWithFetchedResultsController:self.dataResultsController
                                                                                 forTableView:self.tableView];

        __weak typeof(self) weakSelf = self;

        _dataSource.deletionHandler = ^(UITableViewCell *cell, INVAccountMembership *member, NSIndexPath *indexPath) {
            [weakSelf confirmDeletion:indexPath];
        };

        [_dataSource
            registerCellWithIdentifierForAllIndexPaths:@"UserCell"
                                        configureBlock:^(INVCurrentUsersProfileTableViewCell *cell,
                                                           INVAccountMembership *cellData, NSIndexPath *indexPath) {

                                            cell.user = self.cachedUsers[cellData.userId];
                                            cell.expanded = [self.expanded[indexPath] boolValue];

                                            if (weakSelf.dataSource.editableHandler(cellData, indexPath)) {
                                                cell.indentationLevel = 0;
                                                cell.indentationWidth = 0;
                                            }
                                            else {
                                                cell.indentationLevel = 1;
                                                cell.indentationWidth = 38;
                                            }

                                            if (cell.user == nil) {
                                                [self.globalDataManager.invServerClient
                                                    getUserProfileInSignedInAccountWithId:cellData.userId
                                                                      withCompletionBlock:^(id result,
                                                                                              INVEmpireMobileError *error) {
                                                                          weakSelf.cachedUsers[cellData.userId] = result;
                                                                          cell.user = result;
                                                                      }];
                                            }
                                        }];
    }

    return _dataSource;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"userProfileTransition"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        INVUserProfileTableViewController *userProfileController =
            (INVUserProfileTableViewController *) navigationController.topViewController;
        userProfileController.userId = [[self.dataResultsController objectAtIndexPath:indexPath] userId];
    }
}
#pragma mark - helpers
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];
}

@end
