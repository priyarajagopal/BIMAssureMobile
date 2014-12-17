//
//  AlertController+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "UIAlertController+INVCustomizations.h"

@implementation UIAlertController (INVCustomizations)
- (instancetype)initWithErrorMessage:(NSString*)errorMesg{
    UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }];
    
    self= [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR", nil) message:errorMesg preferredStyle:UIAlertControllerStyleAlert];
    if (self) {
        [self.view setTintColor:[UIColor darkGrayColor]];
        [self addAction:action];
    }
    return self;
}

@end
