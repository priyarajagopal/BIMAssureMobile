//
//  UIResponder+IBHelpers.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/9/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "UIResponder+IBHelpers.h"

@implementation UIResponder (IBHelpers)

- (void)scrollToVisibleInParentScrollview
{
    if (![self isKindOfClass:[UIView class]])
        return;

    UIView *view = (UIView *) self;
    UIScrollView *scrollView = nil;
    for (UIView *parent = view; parent != nil; parent = parent.superview) {
        if ([parent isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *) parent;
            break;
        }
    }

    if (scrollView == nil) {
        return;
    }

    CGRect rect = [view convertRect:view.bounds toView:scrollView];
    [scrollView scrollRectToVisible:rect animated:YES];
}

@end
