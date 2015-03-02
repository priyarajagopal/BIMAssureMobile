//
//  INVNotificationPoller.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/14/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVNotificationPoller.h"

NSString *const INVNotificationPoller_DidRecieveNotificationNotification =
    @"INVNotificationPoller_DidRecieveNotificationNotification";
NSString *const INVNotificationPoller_DataSourceKey = @"INVNotificationPoller_DataSourceKey";
NSString *const INVNotificationPoller_ChangesKey = @"INVNotificationPoller_ChangesKey";
NSString *const INVNotificationPoller_NotificationsEnabledKey = @"INVNotificationPoller_NotificationsEnabled";

@interface INVNotificationPollerDataSource ()

@property (copy) void (^block)(void (^)(NSArray *));

@end

@implementation INVNotificationPollerDataSource

- (id)initWithBlock:(void (^)(void (^)(NSArray *)))block
{
    if (self = [super init]) {
        _block = [block copy];
    }

    return self;
}

+ (id)sourceWithBlock:(void (^)(void (^)(NSArray *)))block
{
    return [[self alloc] initWithBlock:block];
}

- (void)checkForNewData:(void (^)(NSArray *))callback
{
    if (_block) {
        _block(callback);
    }
}

@end

@interface INVNotificationPoller ()

@property dispatch_queue_t backgroundQueue;
@property dispatch_source_t pollingTimer;

@property NSMutableArray *dataSources;
@property NSMutableArray *notifications;

@end

@implementation INVNotificationPoller

+ (instancetype)instance
{
    static INVNotificationPoller *poller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        poller = [INVNotificationPoller new];
    });

    return poller;
}

- (void)restartTimer
{
    dispatch_source_set_timer(_pollingTimer, DISPATCH_TIME_NOW, NSEC_PER_SEC * 10, NSEC_PER_SEC * 5);
}

- (void)forceUpdate
{
    [self restartTimer];
}

- (id)init
{
    if (self = [super init]) {
        _backgroundQueue = dispatch_queue_create("INVNotificationPoller", DISPATCH_QUEUE_SERIAL);
        _pollingTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _backgroundQueue);

        dispatch_source_set_event_handler(_pollingTimer, ^{
            [self pollForNotifications];
        });

        _dataSources = [NSMutableArray new];
        _notifications = [NSMutableArray new];

        if (![[NSUserDefaults standardUserDefaults] objectForKey:INVNotificationPoller_NotificationsEnabledKey]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:INVNotificationPoller_NotificationsEnabledKey];
        }

        _notificationsEnabled =
            [[NSUserDefaults standardUserDefaults] boolForKey:INVNotificationPoller_NotificationsEnabledKey];

        [self restartTimer];
    }

    return self;
}

- (void)setNotificationsEnabled:(BOOL)notificationsEnabled
{
    _notificationsEnabled = notificationsEnabled;

    [[NSUserDefaults standardUserDefaults] setBool:notificationsEnabled forKey:INVNotificationPoller_NotificationsEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)pollForNotifications
{
    if (!self.notificationsEnabled)
        return;

    for (INVNotificationPollerDataSource *dataSource in _dataSources) {
        [dataSource checkForNewData:^(NSArray *changes) {
            NSMutableArray *newObjects = [changes mutableCopy];
            NSMutableArray *removedObjects = [changes mutableCopy];

            [newObjects removeObjectsInArray:self->_notifications];
            [removedObjects removeObjectsInArray:newObjects];

            [self->_notifications removeObjectsInArray:removedObjects];
            [self->_notifications addObjectsFromArray:newObjects];

            if (changes.count) {
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:INVNotificationPoller_DidRecieveNotificationNotification
                                  object:self
                                userInfo:@{
                                    INVNotificationPoller_DataSourceKey : dataSource,
                                    INVNotificationPoller_ChangesKey : changes
                                }];
            }
        }];
    }
}

- (NSArray *)allNotifications
{
    return [_notifications
        filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return ![evaluatedObject dismissed];
        }]];
}

- (void)beginPolling
{
    dispatch_resume(_pollingTimer);
}

- (void)endPolling
{
    dispatch_suspend(_pollingTimer);

    [_notifications removeAllObjects];
}

- (void)addDataSource:(INVNotificationPollerDataSource *)dataSource
{
    [_dataSources addObject:dataSource];

    [self restartTimer];
}

- (void)removeDataSource:(INVNotificationPollerDataSource *)dataSource
{
    [_dataSources removeObject:dataSource];
}

@end
