//
//  INVPendingInvitesNotificationDataSource.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVPendingInvitesNotificationDataSource.h"
#import <EmpireMobileManager/INVUserInvite.h>

@interface INVPendingInvitesNotificationDataSource ()

@property NSArray *previousInvites;
@property (nonatomic) NSMutableArray *previousNotifications;

@end

@implementation INVPendingInvitesNotificationDataSource

- (NSMutableArray *)previousNotifications
{
    if (_previousNotifications == nil) {
        _previousNotifications = [NSMutableArray new];
    }

    [_previousNotifications
        removeObjectsAtIndexes:[_previousNotifications indexesOfObjectsPassingTest:^BOOL(INVNotification *notification,
                                                                                       NSUInteger idx, BOOL *stop) {
            return notification.dismissed;
        }]];

    return _previousNotifications;
}

- (void)checkForNewData:(void (^)(NSArray *))callback
{
    if (INVGlobalDataManager.sharedInstance.loggedInUser == nil)
        return;

    [[INVGlobalDataManager sharedInstance]
            .invServerClient getPendingInvitationsForSignedInUserWithCompletionBlock:^(INVEmpireMobileError *error) {
        if (error) {
            INVLogError(@"%@", error);
            return;
        }

        NSArray *invites = [[INVGlobalDataManager sharedInstance].invServerClient.accountManager accountInvitesForUser];
        NSMutableArray *newInvites = [invites mutableCopy];
        NSMutableArray *goneInvites = [self->_previousInvites mutableCopy];

        [newInvites removeObjectsInArray:self->_previousInvites];
        [goneInvites removeObjectsInArray:invites];

        NSMutableArray *notifications = [NSMutableArray new];

        for (INVUserInvite *invite in newInvites) {
            NSString *title = [NSString
                stringWithFormat:NSLocalizedString(@"ACCOUNT_INVITE_NOTIFICATION_RECIEVED_TITLE", nil), [invite accountName]];

            [notifications
                addObject:[INVNotification notificationWithTitle:title type:INVNotificationTypePendingInvite andData:invite]];
        }

        if (goneInvites.count) {
            INVLogDebug();
        }

        NSArray *notificationsToDismiss = [self.previousNotifications
            objectsAtIndexes:[self.previousNotifications indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [goneInvites containsObject:[obj data]];
            }]];

        self->_previousInvites = invites;
        [self.previousNotifications addObjectsFromArray:notifications];

        [notificationsToDismiss enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setDismissed:YES];
        }];

        [notifications addObjectsFromArray:notificationsToDismiss];

        callback(notifications);
    }];
}

@end
