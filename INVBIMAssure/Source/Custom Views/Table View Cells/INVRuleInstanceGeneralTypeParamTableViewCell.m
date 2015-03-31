//
//  INVRuleInstanceDetailTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceGeneralTypeParamTableViewCell.h"

@interface INVRuleInstanceGeneralTypeParamTableViewCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKey;
@property (weak, nonatomic) IBOutlet UITextField *ruleInstanceValue;

@property (weak, nonatomic) IBOutlet UIButton *ruleInstanceUnitsButton;

// Important - this MUST be strong
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ruleInstanceCollapseLayoutConstraint;

@end

@implementation INVRuleInstanceGeneralTypeParamTableViewCell

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

- (void)updateUI
{
    self.ruleInstanceKey.text = self.actualParamDictionary[INVActualParamDisplayName];
    self.ruleInstanceValue.text = self.actualParamDictionary[INVActualParamValue];

    if (self.actualParamDictionary[INVActualParamUnit]) {
        [self.ruleInstanceUnitsButton removeConstraint:self.ruleInstanceCollapseLayoutConstraint];

        if ([self.actualParamDictionary[INVActualParamUnit] length]) {
            [self.ruleInstanceUnitsButton setTitle:self.actualParamDictionary[INVActualParamUnit]
                                          forState:UIControlStateNormal];
        }
        else {
            FAKFontAwesome *downIcon = [FAKFontAwesome arrowDownIconWithSize:30];
            [downIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
            
            [self.ruleInstanceUnitsButton setTitle:NSLocalizedString(@"SELECT_UNIT", nil) forState:UIControlStateNormal];
        }
    }
    else {
        [self.ruleInstanceUnitsButton addConstraint:self.ruleInstanceCollapseLayoutConstraint];
    }
}

#pragma mark - IBActions

- (IBAction)ruleInstanceValueTextChanged:(id)sender
{
    self.actualParamDictionary[INVActualParamValue] = [self.ruleInstanceValue text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    // TODO : Valudate and notify the delegate of issues . Display appropriate error
    if (self.delegate && [self.delegate respondsToSelector:@selector(onValidationFailed:)]) {
        [self.delegate onValidationFailed:self];
    }
    return YES;
}



@end
