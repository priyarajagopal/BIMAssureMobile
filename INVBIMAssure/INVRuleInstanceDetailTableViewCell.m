//
//  INVRuleInstanceDetailTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceDetailTableViewCell.h"

@interface INVRuleInstanceDetailTableViewCell () <UITextFieldDelegate>

@end

@implementation INVRuleInstanceDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UItextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRuleInstanceUpdated:)]) {
        [self.delegate onRuleInstanceUpdated:self];
    }
    return YES;
}

@end
