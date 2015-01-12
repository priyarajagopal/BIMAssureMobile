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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBeginEditingRuleInstanceOverviewField:)]) {
        [self.delegate onBeginEditingRuleInstanceOverviewField:self];

    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onRuleInstanceOverviewUpdated:)]) {
            [self.delegate onRuleInstanceOverviewUpdated:self];
        }
    }
    return YES;
}


@end
