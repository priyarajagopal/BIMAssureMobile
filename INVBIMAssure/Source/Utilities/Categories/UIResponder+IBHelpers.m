//
//  UIResponder+IBHelpers.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/9/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "UIResponder+IBHelpers.h"
#import "UIView+INVCustomizations.h"

@implementation UIResponder (IBHelpers)

- (void)scrollToVisibleInParentScrollview
{
    if (![self isKindOfClass:[UIView class]])
        return;

    UIScrollView *scrollView = [(UIView *) self findSuperviewOfClass:[UIScrollView class] predicate:nil];
    if (scrollView == nil) {
        return;
    }

    CGRect rect = [(UIView *) self convertRect:[(UIView *) self bounds] toView:scrollView];
    [scrollView scrollRectToVisible:rect animated:YES];
}

@end
