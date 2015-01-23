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
#import "INVMainViewController.h"

static inline NSString *invNotificationTypeToString(INVNotificationType type) {
    static NSString *notificationLocalizedStringKeys[] = {
        @"NOTIFICATION_TYPE_PENDING_INVITE",
        @"NOTIFICATION_TYPE_PROJECT"
    };
    
    return NSLocalizedString(notificationLocalizedStringKeys[type], nil);
}

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
    [self reloadData];
}

-(void) reloadData {
    NSArray *notifications = [[INVNotificationPoller instance] allNotifications];
    notifications = [notifications sortedArrayUsingDescriptors: @[
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]
                                                                  ]];
    
    NSMutableArray *notificationSections = [NSMutableArray arrayWithCapacity:INVNotificationTypeCount];
    
    for (int index = 0; index < INVNotificationTypeCount; index++) {
        [notificationSections addObject:[NSMutableArray new]];
    }
    
    for (INVNotification *notification in notifications) {
        [notificationSections[notification.type] addObject:notification];
    }
    
    [notificationSections removeObjectsAtIndexes:[notificationSections indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj count] == 0;
    }]];
    
    self.notifications = [notificationSections copy];
    [self.tableView reloadData];
}

-(void)onRefreshControlSelected:(id)event {
    [self.refreshControl endRefreshing];
    
    [[INVNotificationPoller instance] forceUpdate];
    [self reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = self.notifications.count;
    self.noNotificationsLabel.hidden = count > 0;
    
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notifications[section] count];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    INVNotificationType type = [(INVNotification *)[self.notifications[section] firstObject] type];
    
    return invNotificationTypeToString(type);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    INVNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    
    INVNotification *notification = _notifications[indexPath.section][indexPath.row];
    cell.notification = notification;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    INVNotificationTableViewCell *cell = (INVNotificationTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    INVNotification *notification = cell.notification;
    
    _selectedNotification = notification;
    
    if (notification.type == INVNotificationTypePendingInvite && notification.data) {
        // Handle account invite.
        _alertView = [[[NSBundle mainBundle] loadNibNamed:@"INVDefaultAccountAlertView" owner:nil options:nil] firstObject];
        _alertView.delegate = self;
        _alertView.translatesAutoresizingMaskIntoConstraints = NO;
        _alertView.setAsDefaultContainer.hidden = YES;
        
        [_alertView.acceptButton setTitle:NSLocalizedString(@"INVITE_ACCEPT", nil) forState:UIControlStateNormal];
        [_alertView.cancelButton setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
        
        _alertView.alertMessage.text = [NSString stringWithFormat:NSLocalizedString(@"ARE_YOU_SURE_INVITE_MESSAGE", nil), [notification.data accountName]];
        
        [self.view.window addSubview:_alertView];
        
        [self.view.window addConstraint:[NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.view.window addConstraint:[NSLayoutConstraint constraintWithItem:_alertView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    
    if (notification.type == INVNotificationTypeProject && notification.data) {
        INVProject *project = notification.data;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ARE_YOU_SURE_PROJECT_TITLE", nil)
                                                                                 message:[NSString stringWithFormat:NSLocalizedString(@"ARE_YOU_SURE_PROJECT_MESSAGE", nil), project.name]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ARE_YOU_SURE_PROJECT_NO", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ARE_YOU_SURE_PROJECT_YES", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"unwind" sender:nil];
            
            INVMainViewController *mainViewController = (INVMainViewController *) [[UIApplication sharedApplication] keyWindow].rootViewController;
            [mainViewController viewProject:project];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
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
                                         self.selectedNotification.dismissed = YES;
                                         self.selectedNotification = nil;
                                         
                                         [self reloadData];
                                     }];
}

-(void) onCancelLogintoAccount {
    [_alertView removeFromSuperview];
}

@end
