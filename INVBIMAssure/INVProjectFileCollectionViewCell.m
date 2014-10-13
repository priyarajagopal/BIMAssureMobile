//
//  INVProjectFileCollectionViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFileCollectionViewCell.h"

@implementation INVProjectFileCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    UIColor* whiteColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
    [[UIBarButtonItem appearanceWhenContainedIn:[self class], nil]setTintColor:whiteColor];
}


#pragma mark - UIEvent handlers
- (IBAction)onViewProjectSelected:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onViewProjectFile:)]) {
        [self.delegate onViewProjectFile:self];
    }

}

- (IBAction)onManageRuleSetsSelected:(UIBarButtonItem *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onManageRuleSetsForProjectFile:)]) {
        [self.delegate onManageRuleSetsForProjectFile:sender];
    }

}
@end
