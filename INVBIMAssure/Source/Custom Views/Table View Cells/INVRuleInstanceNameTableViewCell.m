//
//  INVRuleInstanceNameTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/20/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceNameTableViewCell.h"

@interface INVRuleInstanceNameTableViewCell () <UITextFieldDelegate>

@end
@implementation INVRuleInstanceNameTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self.ruleName setTintColor:[UIColor darkGrayColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRuleInstanceNameUpdated:)]) {
        [self.delegate onRuleInstanceNameUpdated:self];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBeginEditingRuleInstanceNameField:)]) {
        [self.delegate onBeginEditingRuleInstanceNameField:self];
    }
    return YES;
}

@end
