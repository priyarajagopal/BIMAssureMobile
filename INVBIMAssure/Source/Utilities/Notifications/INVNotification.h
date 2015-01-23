//
//  INVNotification.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, INVNotificationType) {
    INVNotificationTypePendingInvite,
    INVNotificationTypeProject,
    
    INVNotificationTypeCount
};

@interface INVNotification : NSObject

@property NSString *title;
@property INVNotificationType type;
@property id data;
@property BOOL dismissed;
@property NSDate *creationDate;

+(id) notificationWithTitle:(NSString *) title type:(INVNotificationType) type andData:(id) data;
-(id) initWithTitle:(NSString *) title type:(INVNotificationType) type andData:(id) data;

@end
