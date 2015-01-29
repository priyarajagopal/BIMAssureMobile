//
//  INVLoginScrollView.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/21/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVLoginScrollView.h"

@implementation INVLoginScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

@end
