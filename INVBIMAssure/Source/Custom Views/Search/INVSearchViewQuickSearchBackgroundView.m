//
//  INVSearchViewQuickSearchBackgroundView.m
//  INVBIMAssure
//
//  Created by Richard Ross on 12/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVSearchViewQuickSearchBackgroundView.h"

@implementation INVSearchViewQuickSearchBackgroundView

+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsZero;
}

+ (CGFloat)arrowBase
{
    return 0;
}

+ (CGFloat)arrowHeight
{
    return 0;
}

- (UIPopoverArrowDirection)arrowDirection
{
    return 0;
}

- (CGFloat)arrowOffset
{
    return 0;
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
}

- (void)layoutSubviews
{
    self.layer.shadowOffset = CGSizeZero;
}

@end
