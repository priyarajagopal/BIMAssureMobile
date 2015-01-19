//
//  INVNotificationsTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVNotificationsTableViewController.h"
#import "INVNotificationPoller.h"
#import "INVNotificationTableViewCell.h"

#import "INVDefaultAccountAlertView.h"

@interface INVNotificationsTableViewController ()<INVDefaultAccountAlertViewDelegate>

@property IBOutlet UILabel *noNotificationsLabel;

@property INVDefaultAccountAlertView *alertView;
@property INVNotification *selectedNotification;
@property NSArray *notifications;

@end

@implementation INVNotificationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"INVNotificationTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"notificationCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotificationRecieved:)
                                                 name:INVNotificationPoller_DidRecieveNotificationNotification
                                               object:nil];
    
    [self onNotificationRecieved:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void) onNotificationRecieved:(NSNotification *) notification {
    _notifications = [[INVNotificationPoller instance] allNotifications];
    _notifications = [_notifications sortedArrayUsingDescriptors: @[
        [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]
    ]];
    
    [self.tableView reloadData];
}

-(void)onRefreshControlSelected:(id)event {
    [self.refreshControl endRefreshing];
    
    [[INVNotificationPoller instance] forceUpdate];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // TODO: Different sections based on types of notifications?
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = _notifications.count;
    self.noNotificationsLabel.hidden = count > 0;
    
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    INVNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    
    INVNotification *notification = _notifications[indexPath.row];
    cell.notification = notification;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // TODO: Handle for each type of notification.
    _selectedNotification = _notifications[indexPath.row];
    
    if ([[_selectedNotification data] isKindOfClass:[INVUserInvite class]]) {
        // Handle account invite.
        _alertView = [[[NSBundle mainBundle] loadNibNamed:@"INVDefaultAccountAlertView" owner:nil options:nil] firstObject];
        _alertView.delegate = self;
        _alertView.translatesAutoresizingMaskIntoConstraints = NO;
        _alertView.setAsDefaultContainer.hidden = YES;
        
        [_alertView.acceptButton setTitle:NSLocalizedString(@"INVITE_ACCEPT", nil) forState:UIControlStateNormal];
        [_alertView.cancelButton setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
        
        _alertView.alertMessage.text = [NSString stringWithFormat:NSLocalizedString(@"ARE_YOU_SURE_INVITE_MESSAGE", nil), [_selectedNotification.data accountName]];
        
        [self.view.window addSubview:_alertView];
        
        [self.view.window addConstraint:[NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.view.window addConstraint:[NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) onLogintoAccountWithDefault:(BOOL)isDefault {
    [_alertView removeFromSuperview];
    
    [self.globalDataManager.invServerClient acceptInvite:[[_selectedNotification data] invitationCode]
                                                 forUser:self.globalDataManager.loggedInUser
                                     withCompletionBlock:^(INVEmpireMobileError *error) {
                                                     [[INVNotificationPoller instance] forceUpdate];
                                                 }];
}

-(void) onCancelLogintoAccount {
    [_alertView removeFromSuperview];
}

@end
