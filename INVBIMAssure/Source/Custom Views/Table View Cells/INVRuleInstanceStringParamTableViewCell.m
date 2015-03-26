//
//  INVRuleInstanceDetailTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceStringParamTableViewCell.h"

NSString *const INVActualParamName = @"Name";
NSString *const INVActualParamType = @"Type";
NSString *const INVActualParamValue = @"value"; // Data contains a "value" element

@interface INVRuleInstanceStringParamTableViewCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKey;
@property (weak, nonatomic) IBOutlet UITextField *ruleInstanceValue;

@end

@implementation INVRuleInstanceStringParamTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self updateUI];
}

- (BOOL)becomeFirstResponder
{
    return [self.ruleInstanceValue becomeFirstResponder];
}

#pragma mark - Content Management

- (void)setActualParamDictionary:(INVActualParamKeyValuePair)actualParamDictionary
{
    _actualParamDictionary = actualParamDictionary;

    [self updateUI];
}

- (void)updateUI
{
    self.ruleInstanceKey.text = self.actualParamDictionary[INVActualParamName];
    self.ruleInstanceValue.text = self.actualParamDictionary[INVActualParamValue];
}

#pragma mark - IBActions

- (IBAction)ruleInstanceValueTextChanged:(id)sender
{
    self.actualParamDictionary[INVActualParamValue] = [self.ruleInstanceValue text];
}

@end
