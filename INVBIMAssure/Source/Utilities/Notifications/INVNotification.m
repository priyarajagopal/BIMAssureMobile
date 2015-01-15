//
//  INVNotification.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVNotification.h"

@implementation INVNotification

+(id) notificationWithTitle:(NSString *)title andData:(id)data {
    return [[self alloc] initWithTitle:title andData:data];
}

-(id) initWithTitle:(NSString *)title andData:(id)data {
    if (self = [super init]) {
        self.title = title;
        self.data = data;
    }
    
    return self;
}

@end
