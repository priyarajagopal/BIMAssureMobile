//
//  INVProjectFileCollectionViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFileCollectionViewCell.h"

@implementation INVProjectFileCollectionViewCell

- (void)awakeFromNib
{
    // Initialization code
    UIColor *whiteColor = [UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:1.0];
    [[UIBarButtonItem appearanceWhenContainedIn:[self class], nil] setTintColor:whiteColor];
}

#pragma mark - UIEvent handlers
- (IBAction)onViewProjectSelected:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onViewProjectFile:)]) {
        [self.delegate onViewProjectFile:self];
    }
}

- (IBAction)onManageAnalysesSelected:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onManageRuleSetsForProjectFile:)]) {
        [self.delegate onManageRuleSetsForProjectFile:self];
    }
}

- (IBAction)onRunRulesSelected:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRunRulesForProjectFile:)]) {
        [self.delegate onRunRulesForProjectFile:self];
    }
}

- (IBAction)onShowExecutionsSelected:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onShowExecutionsForProjectFile:)]) {
        [self.delegate onShowExecutionsForProjectFile:self];
    }
}
@end
