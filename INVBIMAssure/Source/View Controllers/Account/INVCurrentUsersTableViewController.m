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

    self.navigationItem.rightBarButtonItem = self.editButtonItem;

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

            NSArray *objects = self.dataResultsController.fetchedObjects;
            id successBlock = [INVBlockUtils blockForExecutingBlock:^{
                [self.tableView reloadData];
            } afterNumberOfCalls:objects.count];

            for (NSManagedObject *membershipObject in objects) {
                INVAccountMembership *membership = [MTLManagedObjectAdapter modelOfClass:[INVAccountMembership class]
                                                                       fromManagedObject:membershipObject
                                                                                   error:nil];

                for (NSNumber *role in membership.roles) {
                    NSNumber *sectionRole = role;
                    if (self.sections[sectionRole] == nil) {
                        self.sections[sectionRole] = [NSMutableArray new];
                    }

                    [self.sections[sectionRole] addObject:membership];
                }

                [self.globalDataManager.invServerClient
                    getUserProfileInSignedInAccountWithId:membership.userId
                                      withCompletionBlock:^(INVUser *user, INVEmpireMobileError *error) {
                                          self.cachedUsers[user.userId] = user;

                                          if ([user.userId isEqual:self.globalDataManager.invServerClient.accountManager
                                                                       .signedinUser.userId]) {
                                              self.sections[SECTION_CURRENT_USER] = @[ membership ];
                                          }

                                          [successBlock invoke];
                                      }];
            }
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
                                  [self performSelectorOnMainThread:@selector(reloadRowAtIndexPath:)
                                                         withObject:indexPath
                                                      waitUntilDone:NO];

                              }];
    }

    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVAccountMembership *member = [self.sections[self.sortedSections[indexPath.section]] objectAtIndex:indexPath.row];

    if (self.cachedUsers[member.userId]) {
        if ([member.userId isEqual:self.globalDataManager.invServerClient.accountManager.signedinUser.userId]) {
            return UITableViewCellEditingStyleNone;
        }

        INVAccountMembership *currentMembership = [self.sections[SECTION_CURRENT_USER] firstObject];
        if (![[currentMembership roles] containsObject:@(INV_MEMBERSHIP_TYPE_ADMIN)]) {
            return UITableViewCellEditingStyleNone;
        }

        return UITableViewCellEditingStyleDelete;
    }

    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVAccountMembership *member = [self.sections[self.sortedSections[indexPath.section]] objectAtIndex:indexPath.row];

    [self.globalDataManager.invServerClient
        removeUserFromSignedInAccountWithUserId:member.userId
                            withCompletionBlock:INV_COMPLETION_HANDLER {
                                INV_ALWAYS:
                                    [self fetchListOfAccountMembers];

                                INV_SUCCESS:

                                INV_ERROR:
                                    INVLogError(@"%@", error);

                                    UIAlertController *errorController = [[UIAlertController alloc]
                                        initWithErrorMessage:NSLocalizedString(@"ERROR_REMOVING_USER", nil)];

                                    [self presentViewController:errorController animated:YES completion:nil];
                            }];
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
- (NSFetchedResultsController *)dataResultsController
{
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = [self.globalDataManager.invServerClient.accountManager fetchRequestForAccountMembership];

        _dataResultsController = [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.globalDataManager.invServerClient.accountManager.managedObjectContext
              sectionNameKeyPath:nil
                       cacheName:nil];
    }

    return _dataResultsController;
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

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
}

@end
