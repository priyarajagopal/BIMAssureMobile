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

@property (weak, nonatomic) IBOutlet UIButton *unitsButton;

// Important - this MUST be strong
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *unitsButtonCollapseLayoutConstraint;

@property IBOutlet UIView *errorContainerView;
@property IBOutlet UILabel *errorMessageLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *errorContainerCollapseLayoutConstraint;

@end

@implementation INVRuleInstanceGeneralTypeParamTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

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
        [self.unitsButton removeConstraint:self.unitsButtonCollapseLayoutConstraint];

        if ([self.actualParamDictionary[INVActualParamUnit] isKindOfClass:[NSNull class]]) {
            [self.unitsButton setTitle:NSLocalizedString(@"SELECT_UNIT", nil) forState:UIControlStateNormal];
        }
        else {
            [self.unitsButton setTitle:self.actualParamDictionary[INVActualParamUnit] forState:UIControlStateNormal];
        }
    }
    else {
        [self.unitsButton addConstraint:self.unitsButtonCollapseLayoutConstraint];
    }

    if ([self tintColor]) {
        self.ruleInstanceKey.textColor = self.tintColor;
        self.ruleInstanceValue.textColor = self.tintColor;
        self.unitsButton.titleLabel.textColor = self.tintColor;
    }

    if (self.actualParamDictionary[INVActualParamError]) {
        self.errorContainerView.hidden = NO;
        [self.errorContainerView removeConstraint:self.errorContainerCollapseLayoutConstraint];

        self.errorMessageLabel.text = self.actualParamDictionary[INVActualParamError];
    }
    else {
        self.errorContainerView.hidden = YES;
        [self.errorContainerView addConstraint:self.errorContainerCollapseLayoutConstraint];
    }

    [self setNeedsLayout];
    [self setNeedsUpdateConstraints];
}

- (void)setActualParamDictionary:(INVActualParamKeyValuePair)actualParamDictionary
{
    _actualParamDictionary = actualParamDictionary;

    [self updateUI];
}

#pragma mark - IBActions

- (IBAction)ruleInstanceValueTextChanged:(id)sender
{
    NSError *error = [[INVRuleParameterParser instance] isValueValid:self.ruleInstanceValue.text
                                                   forAnyTypeInArray:self.actualParamDictionary[INVActualParamType]
                                                     withConstraints:self.actualParamDictionary[INVActualParamTypeConstraints]];
    if (error) {
        self.actualParamDictionary[INVActualParamError] = error.localizedDescription;

        [self updateUI];

        UITableView *tableView = [self findSuperviewOfClass:[UITableView class] predicate:nil];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
    else {
        self.actualParamDictionary[INVActualParamValue] = [self.ruleInstanceValue text];
        [self.actualParamDictionary removeObjectForKey:INVActualParamError];

        [self updateUI];

        UITableView *tableView = [self findSuperviewOfClass:[UITableView class] predicate:nil];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

@end
