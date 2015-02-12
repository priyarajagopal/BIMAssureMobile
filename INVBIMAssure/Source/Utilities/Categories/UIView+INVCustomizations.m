//
//  UIView+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "UIView+INVCustomizations.h"

@implementation UIView (INVCustomizations)

- (id)findSuperviewOfClass:(Class)kls predicate:(NSPredicate *)predicate
{
    if (kls == nil || [self isKindOfClass:kls]) {
        if (predicate == nil || [predicate evaluateWithObject:self]) {
            return self;
        }
    }

    return [self.superview findSuperviewOfClass:kls predicate:predicate];
}

- (id)findSubviewOfClass:(Class)kls predicate:(NSPredicate *)predicate
{
    if (kls == nil || [self isKindOfClass:kls]) {
        if (predicate == nil || [predicate evaluateWithObject:self]) {
            return self;
        }
    }

    for (UIView *subview in self.subviews) {
        id results = [subview findSubviewOfClass:kls predicate:predicate];
        if (results) {
            return results;
        }
    }

    return nil;
}

@end
