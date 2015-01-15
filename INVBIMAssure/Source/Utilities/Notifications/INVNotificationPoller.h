//
//  INVNotificationPoller.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/14/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INVNotification.h"

extern NSString *const INVNotificationPoller_DidRecieveNotificationNotification;
extern NSString *const INVNotificationPoller_DataSourceKey;
extern NSString *const INVNotificationPoller_ChangesKey;

@interface INVNotificationPollerDataSource : NSObject

-(instancetype) initWithBlock:(void (^)(void (^)(NSArray *callback))) block;
+(instancetype) sourceWithBlock:(void (^)(void (^)(NSArray *callback))) block;

-(void) checkForNewData:(void (^)(NSArray *)) callback;

@end

@interface INVNotificationPoller : NSObject

+(instancetype) instance;
-(NSArray *) allNotifications;

-(void) beginPolling;
-(void) endPolling;

-(void) addDataSource:(INVNotificationPollerDataSource *) dataSource;
-(void) removeDataSource:(INVNotificationPollerDataSource *) dataSource;

@end
