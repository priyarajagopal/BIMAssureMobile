//
//  INVRuleInstanceNameTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/20/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVTextFieldTableViewCell.h"

@interface INVTextFieldTableViewCell () <UITextFieldDelegate>

@end
@implementation INVTextFieldTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self.detail setTintColor:[UIColor darkGrayColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)becomeFirstResponder
{
    return [self.detail becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTextFieldUpdated:)]) {
        [self.delegate onTextFieldUpdated:self];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBeginEditingTextField:)]) {
        [self.delegate onBeginEditingTextField:self];
    }
    return YES;
}

@end
