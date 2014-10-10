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
- (IBAction)setAsDefaultAccountSwitchToggled:(id)sender {
}

- (IBAction)onLogintoAccount:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onLogintoAccountWithDefault:)]) {
        [self.delegate onLogintoAccountWithDefault:self.defaultSwitch.isOn];
    }
}

- (IBAction)onCancelLogin:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCancelLogintoAccount)]) {
        [self.delegate onCancelLogintoAccount];
    }
}

/*
- (void)registerForNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(setUpForOrientation)
               name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) setConstraints {
    NSLayoutConstraint* xConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint* yConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self addConstraints:@[xConstraint,yConstraint]];
    
}

- (void)setUpForOrientation {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (orientation == UIDeviceOrientationPortrait)
    {
        CGAffineTransform affine = CGAffineTransformMakeRotation (0.0);
        [self setTransform:affine];
    }
    
    if (orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        CGAffineTransform affine = CGAffineTransformMakeRotation (M_PI * 180 / 180.0f);
        [self setTransform:affine];
    }
    else if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        CGAffineTransform affine = CGAffineTransformMakeRotation (M_PI * 90 / 180.0f);
        
        [self setTransform:affine];
    }
    else if (orientation == UIDeviceOrientationLandscapeRight)
    {
        CGAffineTransform affine = CGAffineTransformMakeRotation ( M_PI * 270 / 180.0f);
         [self setTransform:affine];
    }
}
 */

@end
