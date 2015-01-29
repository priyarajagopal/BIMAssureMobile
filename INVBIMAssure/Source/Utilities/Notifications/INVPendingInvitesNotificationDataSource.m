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

@end

@implementation INVPendingInvitesNotificationDataSource

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

        /*
        for (INVUserInvite *invite in goneInvites) {
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"ACCOUNT_INVITE_NOTIFICATION_ACCEPTED_TITLE", nil),
        [invite accountName]];

            [notifications addObject:[INVNotification notificationWithTitle:title type:INVNotificationTypePendingInvite
        andData:nil]];
        }
         */

        self->_previousInvites = invites;

        callback(notifications);
    }];
}

@end
