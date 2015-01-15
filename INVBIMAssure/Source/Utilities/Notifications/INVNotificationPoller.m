//
//  INVNotificationPoller.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/14/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVNotificationPoller.h"

NSString *const INVNotificationPoller_DidRecieveNotificationNotification = @"INVNotificationPoller_DidRecieveNotificationNotification";
NSString *const INVNotificationPoller_DataSourceKey = @"INVNotificationPoller_DataSourceKey";
NSString *const INVNotificationPoller_ChangesKey = @"INVNotificationPoller_ChangesKey";

@implementation INVNotificationPollerDataSource {
    void (^_block)(void (^)(NSArray *));
}

-(id) initWithBlock:(void (^)(void (^)(NSArray *)))block {
    if (self = [super init]) {
        _block = [block copy];
    }
    
    return self;
}

+(id) sourceWithBlock:(void (^)(void (^)(NSArray *)))block {
    return [[self alloc] initWithBlock:block];
}

-(void) checkForNewData:(void (^)(NSArray *))callback {
    if (_block) {
        _block(callback);
    }
}

@end

@implementation INVNotificationPoller {
    dispatch_queue_t _backgroundQueue;
    dispatch_source_t _pollingTimer;
    
    NSMutableArray *_dataSources;
}

+(instancetype) instance {
    static INVNotificationPoller *poller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        poller = [INVNotificationPoller new];
    });
    
    return poller;
}

-(void) restartTimer {
    dispatch_source_set_timer(_pollingTimer, DISPATCH_TIME_NOW, NSEC_PER_SEC * 10, NSEC_PER_SEC * 5);
}

-(id) init {
    if (self = [super init]) {
        _backgroundQueue = dispatch_queue_create("INVNotificationPoller", DISPATCH_QUEUE_SERIAL);
        _pollingTimer = dispatch_source_create(
            DISPATCH_SOURCE_TYPE_TIMER, 0,
            0, _backgroundQueue
        );
        
        dispatch_source_set_event_handler(_pollingTimer, ^{
            [self pollForNotifications];
        });
        
        _dataSources = [NSMutableArray new];
        
        [self restartTimer];
    }
    
    return self;
}

-(void) pollForNotifications {
    for (INVNotificationPollerDataSource *dataSource in _dataSources) {
        [dataSource checkForNewData:^(NSArray *newData) {
            if (newData.count) {
                [[NSNotificationCenter defaultCenter] postNotificationName:INVNotificationPoller_DidRecieveNotificationNotification
                                                                    object:self
                                                                  userInfo:@{
                                                                        INVNotificationPoller_DataSourceKey: dataSource,
                                                                        INVNotificationPoller_ChangesKey: newData
                                                                    }];
            }
        }];
    }
}

-(void) beginPolling {
    dispatch_resume(_pollingTimer);
}

-(void) endPolling {
    dispatch_suspend(_pollingTimer);
}

-(void) addDataSource:(INVNotificationPollerDataSource *)dataSource {
    [_dataSources addObject:dataSource];
    
    [self restartTimer];
}

-(void) removeDataSource:(INVNotificationPollerDataSource *)dataSource {
    [_dataSources removeObject:dataSource];
}

@end
