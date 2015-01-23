//
//  INVNotification.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVNotification.h"

@implementation INVNotification

+(id) notificationWithTitle:(NSString *)title type:(INVNotificationType)type andData:(id)data {
    return [[self alloc] initWithTitle:title type:type andData:data];
}

-(id) initWithTitle:(NSString *)title type:(INVNotificationType)type andData:(id)data {
    if (self = [super init]) {
        self.title = title;
        self.type = type;
        self.data = data;
        self.creationDate = [NSDate date];
    }
    
    return self;
}

@end
