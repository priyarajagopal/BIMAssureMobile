//
//  INVNotification.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVNotification : NSObject

@property NSString *title;
@property id data;
@property NSDate *creationDate;

+(id) notificationWithTitle:(NSString *) title andData:(id) data;
-(id) initWithTitle:(NSString *) title andData:(id) data;

@end
