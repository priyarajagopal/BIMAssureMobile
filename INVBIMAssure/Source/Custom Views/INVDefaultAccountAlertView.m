//
//  INVDefaultAccountAlertView.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/8/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

@import QuartzCore;

#import "INVDefaultAccountAlertView.h"

@implementation INVDefaultAccountAlertView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect {
}
*/

#pragma mark - UIEvent handlers
- (IBAction)setAsDefaultAccountSwitchToggled:(id)sender
{
}

- (IBAction)onAccept:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onAcceptButtonSelectedWithDefault:)]) {
        [self.delegate onAcceptButtonSelectedWithDefault:self.defaultSwitch.isOn];
    }
}

- (IBAction)onCancel:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCancelButtonSelected)]) {
        [self.delegate onCancelButtonSelected];
    }
}

@end
