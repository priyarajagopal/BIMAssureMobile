//
//  INVRunRuleSetHeaderView.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/2/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRunRuleSetHeaderView.h"

@implementation INVRunRuleSetHeaderView

- (void)awakeFromNib
{
    // Initialization code
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (IBAction)onRunRuleSetToggled:(UIButton *)sender
{
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onRuleSetToggled:)]) {
        [self.actionDelegate onRuleSetToggled:self];
    }
}

@end
