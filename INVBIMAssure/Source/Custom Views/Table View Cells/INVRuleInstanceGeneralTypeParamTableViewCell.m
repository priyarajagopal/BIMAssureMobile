//
//  INVRuleInstanceDetailTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceGeneralTypeParamTableViewCell.h"

#import "UIView+INVCustomizations.h"

@interface INVRuleInstanceGeneralTypeParamTableViewCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKey;
@property (weak, nonatomic) IBOutlet UITextField *ruleInstanceValue;

@property (weak, nonatomic) IBOutlet UIButton *ruleInstanceUnitsButton;

// Important - this MUST be strong
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ruleInstanceCollapseLayoutConstraint;

@property IBOutlet UIView *errorContainerView;
@property IBOutlet UILabel *errorMessageLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *errorContainerCollapseLayoutConstraint;

@property NSString *currentError;

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

    if ([self.actualParamDictionary[INVActualParamValue] isKindOfClass:[NSNull class]]) {
        self.actualParamDictionary[INVActualParamValue] = @"";
    }

    self.ruleInstanceValue.text = self.actualParamDictionary[INVActualParamValue];

    if (self.actualParamDictionary[INVActualParamUnit]) {
        [self.ruleInstanceUnitsButton removeConstraint:self.ruleInstanceCollapseLayoutConstraint];

        if ([self.actualParamDictionary[INVActualParamUnit] isKindOfClass:[NSNull class]]) {
            [self.ruleInstanceUnitsButton setTitle:NSLocalizedString(@"SELECT_UNIT", nil) forState:UIControlStateNormal];
        }
        else {
            [self.ruleInstanceUnitsButton setTitle:self.actualParamDictionary[INVActualParamUnit]
                                          forState:UIControlStateNormal];
        }
    }
    else {
        [self.ruleInstanceUnitsButton addConstraint:self.ruleInstanceCollapseLayoutConstraint];
    }

    if ([self tintColor]) {
        self.ruleInstanceKey.textColor = self.tintColor;
        self.ruleInstanceValue.textColor = self.tintColor;
        self.ruleInstanceUnitsButton.titleLabel.textColor = self.tintColor;
    }

    if (self.currentError) {
        self.errorContainerView.hidden = NO;
        [self.errorContainerView removeConstraint:self.errorContainerCollapseLayoutConstraint];

        self.errorMessageLabel.text = self.currentError;
    }
    else {
        self.errorContainerView.hidden = YES;
        [self.errorContainerView addConstraint:self.errorContainerCollapseLayoutConstraint];
    }
}

#pragma mark - IBActions

- (IBAction)ruleInstanceValueTextChanged:(id)sender
{
    if ([[INVRuleParameterParser instance] isValueValid:self.ruleInstanceValue.text
                                      forAnyTypeInArray:self.actualParamDictionary[INVActualParamType]
                                        withConstraints:self.actualParamDictionary[INVActualParamTypeConstraints]]) {
        self.actualParamDictionary[INVActualParamValue] = [self.ruleInstanceValue text];
    }
    else {
        self.currentError = @"Invalid Input Parameter";
        [self updateUI];

        dispatch_async(dispatch_get_main_queue(), ^{
            UITableView *tableView = [self findSuperviewOfClass:[UITableView class] predicate:nil];

            [tableView reloadData];
        });
    }
}

@end
