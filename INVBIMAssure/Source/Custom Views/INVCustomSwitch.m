//
//  INVCustomSwitch.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/25/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomSwitch.h"

@import ObjectiveC.runtime;

@implementation INVCustomSwitch

- (BOOL)_inv_previouslyOn
{
    static const void *previouslyOnKey = &previouslyOnKey;
    id result = objc_getAssociatedObject(self, previouslyOnKey);
    objc_setAssociatedObject(self, previouslyOnKey, @([self isOn]), OBJC_ASSOCIATION_RETAIN);

    return [result boolValue];
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    NSArray *actions = [self actionsForTarget:target forControlEvent:UIControlEventValueChanged];
    if ([self _inv_previouslyOn] == [self isOn] && [actions containsObject:NSStringFromSelector(action)]) {
        return;
    }

    [super sendAction:action to:target forEvent:event];
}

@end