//
//  INVRuleInstanceTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewCell.h"
#import "UILabel+INVCustomizations.h"
#import "UIFont+INVCustomizations.h"

@interface INVRuleInstanceTableViewCell () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@property (nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic) IBOutlet UILabel *overviewLabel;
@property (nonatomic) IBOutlet UILabel *ruleWarningLabel;
@property (nonatomic) IBOutlet NSLayoutConstraint *collapseRuleWarningConstraint;

@end

@implementation INVRuleInstanceTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self updateUI];
}

- (void)updateUI
{
    if (self.ruleInstance) {
        [self.nameLabel setText:self.ruleInstance.ruleName
                    withDefault:NSLocalizedString(@"RULE_NAME_UNAVAILABLE", nil)
                  andAttributes:@{NSFontAttributeName : self.overviewLabel.font.italicFont}];

        [self.overviewLabel setText:self.ruleInstance.overview
                        withDefault:NSLocalizedString(@"RULE_OVERVIEW_UNAVAILABLE", nil)
                      andAttributes:@{NSFontAttributeName : self.overviewLabel.font.italicFont}];

        if ([self.ruleInstance.emptyParamCount integerValue] > 0) {
            [self.ruleWarningLabel removeConstraint:self.collapseRuleWarningConstraint];
        }
        else {
            [self.ruleWarningLabel addConstraint:self.collapseRuleWarningConstraint];
        }
    }
}

- (void)setRuleInstance:(INVRuleInstance *)rule
{
    _ruleInstance = rule;

    [self updateUI];
}

@end
