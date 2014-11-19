//
//  INVRuleInstanceOverviewTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/19/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceOverviewTableViewCell.h"

@interface INVRuleInstanceOverviewTableViewCell () <UITextFieldDelegate, UITextViewDelegate>
@end

@implementation INVRuleInstanceOverviewTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.ruleDescription setTintColor:[UIColor darkGrayColor]];
    [self.ruleName setTintColor:[UIColor darkGrayColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRuleInstanceOverviewUpdated:)]) {
        [self.delegate onRuleInstanceOverviewUpdated:self];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBeginEditingRuleInstanceOverviewField:)]) {
        [self.delegate onBeginEditingRuleInstanceOverviewField:self];
    }
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRuleInstanceOverviewUpdated:)]) {
        [self.delegate onRuleInstanceOverviewUpdated:self];
    }
    return YES;
}

#warning Detect return
@end
