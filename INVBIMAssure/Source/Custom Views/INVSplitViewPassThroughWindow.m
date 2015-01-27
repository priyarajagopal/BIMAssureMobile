//
//  INVSplitViewPassThroughWindow.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/27/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVSplitViewPassThroughWindow.h"

@implementation INVSplitViewPassThroughWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isKindOfClass:NSClassFromString(@"UIDimmingView")]) {
        for (UIView *passthrough in self.passthroughViews) {
            CGPoint transformedPoint = [passthrough convertPoint:point fromView:self];
            UIView *hit = [passthrough hitTest:transformedPoint withEvent:event];
            if (hit) {
                return hit;
            }
        }
    }
    
    return view;
}

@end
