//
//  INVInvitedUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/22/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVInvitedUsersTableViewController.h"
#import "INVPendingInviteCell.h"
#import "INVBlockUtils.h"

#import <VENTokenField/VENTokenField.h>

@import MessageUI;

static const NSInteger DEFAULT_CELL_HEIGHT = 70;

@interface INVInvitedUsersTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, readwrite) NSFetchedResultsController *dataResultsController;
@property (nonatomic, strong) INVAccountManager *accountManager;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSMutableDictionary *cachedUsers;
@property (nonatomic, assign) BOOL isNSFetchedResultsChangeTypeUpdated;

@end

@implementation INVInvitedUsersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"INVITED_USERS", nil);

    self.tableView.editing = YES;
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;

    self.cachedUsers = [NSMutableDictionary new];

    [self.tableView registerNib:[UINib nibWithNibName:@"INVPendingInviteCell" bundle:nil] forCellReuseIdentifier:@"InviteCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self fetchListOfInvitedUsers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.dateFormatter = nil;
    self.accountManager = nil;
    self.dataResultsController = nil;
}

#pragma mark - server side
- (void)fetchListOfInvitedUsers
{
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }

    [self.globalDataManager.invServerClient getPendingInvitationsSignedInAccountWithCompletionBlock:INV_COMPLETION_HANDLER {
        INV_ALWAYS:
            [self.refreshControl endRefreshing];
            [self.hud hide:YES];

        INV_SUCCESS : {
            [self.dataResultsController performFetch:NULL];

            NSArray *objects = self.dataResultsController.fetchedObjects;
   
            id successBlock = [INVBlockUtils blockForExecutingBlock:^{
                [self.tableView reloadData];
            } afterNumberOfCalls:objects.count];

            for (INVInvite *invite in self.dataResultsController.fetchedObjects) {
                // Because a user's email can never, change, don't request their profile over and over.
                if (self.cachedUsers[invite.createdBy]) {
                    [successBlock invoke];
                    continue;
                }

                [self.globalDataManager.invServerClient
                    getUserProfileInSignedInAccountWithId:invite.createdBy
                                      withCompletionBlock:^(INVUser *result, INVEmpireMobileError *error) {
                                          self.cachedUsers[result.userId] = result;

                                          [successBlock invoke];
                                      }];
            }
        }

        INV_ERROR:
            INVLogError(@"%@", error);

            UIAlertController *errController = [[UIAlertController alloc]
                initWithErrorMessage:NSLocalizedString(@"ERROR_LISTOFINVITEDUSERS_LOAD", nil), error.code.integerValue];
            [self presentViewController:errController animated:YES completion:nil];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ComposeMailSegue"]) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailVC = segue.destinationViewController;
            [mailVC setToRecipients:@[ @"r1_priya@yahoo.com" ]];
            [mailVC setSubject:@"test"];
        }
        else {
            UIAlertController *errController =
                [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_MAILNOTCONFIGURED", nil)];
            [self presentViewController:errController animated:YES completion:nil];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataResultsController.sections[section] numberOfObjects];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        INVInvite *invite = [self.dataResultsController objectAtIndexPath:indexPath];

        UIAlertController *confirmDeleteController =
            [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CONFIRM_CANCEL_INVITE", nil)
                                                message:NSLocalizedString(@"CONFIRM_CANCEL_INVITE_MESSAGE", nil)
                                         preferredStyle:UIAlertControllerStyleAlert];

        [confirmDeleteController
            addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_CANCEL_INVITE_NEGATIVE", nil)
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];

        [confirmDeleteController
            addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CONFIRM_CANCEL_INVITE_POSITIVE", nil)
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action) {
                                                 [self.globalDataManager.invServerClient
                                                     cancelInviteWithInvitationId:invite.invitationId
                                                              withCompletionBlock:INV_COMPLETION_HANDLER {
                                                                  INV_ALWAYS:

                                                                  INV_SUCCESS:

                                                                  INV_ERROR:
                                                                      INVLogError(@"%@", error);
                                                              }];
                                             }]];

        [self presentViewController:confirmDeleteController animated:YES completion:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVPendingInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell" forIndexPath:indexPath];
    cell.invite = [self.dataResultsController objectAtIndexPath:indexPath];
    cell.invitedBy = self.cachedUsers[cell.invite.createdBy];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"CANCEL", nil);
}

- (INVAccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = self.globalDataManager.invServerClient.accountManager;
    }
    return _accountManager;
}


#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.isNSFetchedResultsChangeTypeUpdated) {
        [self.tableView  reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    self.isNSFetchedResultsChangeTypeUpdated = (type == NSFetchedResultsChangeUpdate);
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
}


#pragma mark - accessors

- (NSFetchedResultsController *)dataResultsController
{
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = self.accountManager.fetchRequestForPendingInvitesForAccount;
        fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO] ];
        
        _dataResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:self.accountManager.managedObjectContext
                                                  sectionNameKeyPath:nil
                                                           cacheName:nil];
        _dataResultsController.delegate = self;
    }
    return _dataResultsController;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

#pragma mark - UIRefreshControl
- (void)onRefreshControlSelected:(id)event
{
    [self fetchListOfInvitedUsers];
}

#pragma mark - helper
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

@end
