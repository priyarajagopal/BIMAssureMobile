//
//  UISwitch+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "UISwitch+INVCustomizations.h"
#import "INVRuntimeUtils.h"

#ifdef USE_UISWITCH_HACK

@import ObjectiveC.runtime;

static void (*oldSendAction)(id, SEL, SEL, id, UIEvent *);

@implementation UISwitch (INVCustomizations)

- (BOOL)_inv_previouslyOn
{
    static const void *previouslyOnKey = &previouslyOnKey;
    id result = objc_getAssociatedObject(self, previouslyOnKey);
    objc_setAssociatedObject(self, previouslyOnKey, @([self isOn]), OBJC_ASSOCIATION_RETAIN);

    return [result boolValue];
}

- (void)_inv_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    NSArray *actions = [self actionsForTarget:target forControlEvent:UIControlEventValueChanged];
    if ([self _inv_previouslyOn] == [self isOn] && [actions containsObject:NSStringFromSelector(action)]) {
        return;
    }

    oldSendAction(self, _cmd, action, target, event);
}

@end

__attribute__((constructor)) static void UISwitch_INVCustomizations_Init()
{
    Class kls = [UISwitch class];

    oldSendAction = (void *) safeSwapMethods(kls, @selector(sendAction:to:forEvent:), @selector(_inv_sendAction:to:forEvent:));
}

#endif