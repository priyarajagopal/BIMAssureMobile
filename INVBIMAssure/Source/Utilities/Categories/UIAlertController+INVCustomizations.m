//
//  AlertController+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "UIAlertController+INVCustomizations.h"

@implementation UIAlertController (INVCustomizations)
- (instancetype)initWithErrorMessage:(NSString *)errorMesg, ...
{
    va_list args;
    va_start(args, errorMesg);

    errorMesg = [[NSString alloc] initWithFormat:errorMesg arguments:args];

    va_end(args);

    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];

    self = [UIAlertController alertControllerWithTitle:nil message:errorMesg preferredStyle:UIAlertControllerStyleAlert];

    if (self) {
        [[UIView appearanceWhenContainedIn:[self class], nil] setTintColor:[UIColor darkGrayColor]];
        [self addAction:action];
    }

    return self;
}

@end
