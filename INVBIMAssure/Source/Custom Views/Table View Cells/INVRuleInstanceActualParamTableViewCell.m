//
//  INVRuleInstanceDetailTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceActualParamTableViewCell.h"

@interface INVRuleInstanceActualParamTableViewCell () <UITextFieldDelegate>

@end

@implementation INVRuleInstanceActualParamTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRuleInstanceActualParamUpdated:)]) {
        [self.delegate onRuleInstanceActualParamUpdated:self];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBeginEditingRuleInstanceActualParamField:)]) {
        [self.delegate onBeginEditingRuleInstanceActualParamField:self];
    }
    return YES;
}
@end
