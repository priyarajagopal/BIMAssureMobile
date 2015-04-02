//
//  INVRuleInstanceRangeTypeParamTableViewCell.xib
//  INVBIMAssure
//
//  Created by Richard Ross on 4/1/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceRangeTypeParamTableViewCell.h"

@interface INVRuleInstanceRangeTypeParamTableViewCell ()

@property IBOutlet UILabel *parameterNameLabel;

@property IBOutlet UILabel *fromLabel;
@property IBOutlet UILabel *toLabel;

@property IBOutlet NSLayoutConstraint *fromUnitCollapseConstraint;
@property IBOutlet NSLayoutConstraint *toUnitCollapseConstraint;

@property IBOutlet UIButton *fromUnitButton;
@property IBOutlet UIButton *toUnitButton;

@property IBOutlet UITextField *fromValueField;
@property IBOutlet UITextField *toValueField;

- (IBAction)fromValueTextChanged:(id)sender;
- (IBAction)toValueTextChanged:(id)sender;

@end

@implementation INVRuleInstanceRangeTypeParamTableViewCell

- (void)layoutSubviews
{
    [self updateUI];
    [super layoutSubviews];
}

- (void)updateUI
{
    NSDictionary *constraints = self.actualParamDictionary[INVActualParamTypeConstraints][@(INVParameterTypeRange)];

    self.parameterNameLabel.text = self.actualParamDictionary[INVActualParamDisplayName];

    if ([self.actualParamDictionary[INVActualParamValue] isKindOfClass:[NSNull class]]) {
        self.actualParamDictionary[INVActualParamValue] = [@{
            @"from" : [@{@"value" : [NSNull null]} mutableCopy],
            @"to" : [@{@"value" : [NSNull null]} mutableCopy]
        } mutableCopy];

        if (constraints[@"from_unit"]) {
            self.actualParamDictionary[INVActualParamValue][@"from"][@"unit"] = [NSNull null];
        }

        if (constraints[@"to_unit"]) {
            self.actualParamDictionary[INVActualParamValue][@"to"][@"unit"] = [NSNull null];
        }
    }

    id fromValue = self.actualParamDictionary[INVActualParamValue][@"from"][@"value"];
    id toValue = self.actualParamDictionary[INVActualParamValue][@"to"][@"value"];

    self.fromValueField.text = [fromValue isKindOfClass:[NSNull class]] ? @"" : [fromValue description];
    self.toValueField.text = [toValue isKindOfClass:[NSNull class]] ? @"" : [toValue description];

    self.fromLabel.text = constraints[@"from_display"];
    self.toLabel.text = constraints[@"to_display"];

    [self.fromUnitButton removeConstraint:self.fromUnitCollapseConstraint];
    [self.toUnitButton removeConstraint:self.toUnitCollapseConstraint];

    id fromUnit = self.actualParamDictionary[INVActualParamValue][@"from"][@"unit"];
    if (fromUnit == nil) {
        [self.fromUnitButton addConstraint:self.fromUnitCollapseConstraint];
    }
    else if ([fromUnit isKindOfClass:[NSNull class]]) {
        [self.fromUnitButton setTitle:NSLocalizedString(@"SELECT_UNIT", nil) forState:UIControlStateNormal];
    }
    else {
        [self.fromUnitButton setTitle:fromUnit forState:UIControlStateNormal];
    }

    id toUnit = self.actualParamDictionary[INVActualParamValue][@"to"][@"unit"];
    if (toUnit == nil) {
        [self.toUnitButton addConstraint:self.toUnitCollapseConstraint];
    }
    else if ([toUnit isKindOfClass:[NSNull class]]) {
        [self.toUnitButton setTitle:NSLocalizedString(@"SELECT_UNIT", nil) forState:UIControlStateNormal];
    }
    else {
        [self.toUnitButton setTitle:toUnit forState:UIControlStateNormal];
    }
}

#pragma mark - IBActions

- (void)fromValueTextChanged:(id)sender
{
    NSMutableDictionary *newValue = [self.actualParamDictionary[INVActualParamValue] mutableCopy];
    newValue[@"from"][@"value"] = self.fromValueField.text;

    if ([[INVRuleParameterParser instance] isValueValid:newValue
                                      forAnyTypeInArray:self.actualParamDictionary[INVActualParamType]
                                        withConstraints:self.actualParamDictionary[INVActualParamTypeConstraints]]) {
        self.actualParamDictionary[INVActualParamValue] = newValue;
    }

    [self updateUI];
}

- (void)toValueTextChanged:(id)sender
{
    NSMutableDictionary *newValue = [self.actualParamDictionary[INVActualParamValue] mutableCopy];
    newValue[@"to"][@"value"] = self.toValueField.text;

    if ([[INVRuleParameterParser instance] isValueValid:newValue
                                      forAnyTypeInArray:self.actualParamDictionary[INVActualParamType]
                                        withConstraints:self.actualParamDictionary[INVActualParamTypeConstraints]]) {
        self.actualParamDictionary[INVActualParamValue] = newValue;
    }

    [self updateUI];
}

@end
