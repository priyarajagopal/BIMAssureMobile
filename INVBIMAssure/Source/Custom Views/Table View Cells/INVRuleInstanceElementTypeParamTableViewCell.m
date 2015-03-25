//
//  INVRuleInstanceElementTypeParamTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/24/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceElementTypeParamTableViewCell.h"

@interface INVRuleInstanceElementTypeParamTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKey;
@property (weak, nonatomic) IBOutlet UIButton *ruleInstanceElementType;

@end

@implementation INVRuleInstanceElementTypeParamTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self updateUI];
}

#pragma mark - Content Management

- (void)updateUI
{
    self.ruleInstanceKey.text = self.actualParamDictionary[INVActualParamName];

    if ([self.actualParamDictionary[INVActualParamValue] length]) {
        [self.ruleInstanceElementType setTitle:self.actualParamDictionary[INVActualParamValue]
                                      forState:UIControlStateNormal];
    }
    else {
        [self.ruleInstanceElementType setTitle:NSLocalizedString(@"SELECT_ELEMENT_TYPE", nil) forState:UIControlStateNormal];
    }
}

- (void)setActualParamDictionary:(INVActualParamKeyValuePair)actualParamDictionary
{
    _actualParamDictionary = actualParamDictionary;

    [self updateUI];
}

@end
