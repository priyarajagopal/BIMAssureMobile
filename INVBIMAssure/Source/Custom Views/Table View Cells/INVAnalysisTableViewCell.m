//
//  INVAnalysisTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisTableViewCell.h"

@interface INVAnalysisTableViewCell ()

@property IBOutlet UILabel *analysisNameLabel;
@property IBOutlet UILabel *analysisDescriptionLabel;
@property IBOutlet UIButton *ruleCountButton;

@property IBOutlet UILabel *emptyRulesLabel;
@property IBOutlet NSLayoutConstraint *collapseEmptyRulesConstraint;

@end

@implementation INVAnalysisTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self updateUI];
}

- (void)setAnalysis:(INVAnalysis *)analysis
{
    _analysis = analysis;

    [self updateUI];
}

- (void)updateUI
{
    if (self.analysis) {
        self.analysisNameLabel.text = self.analysis.name;
        self.analysisDescriptionLabel.text = self.analysis.overview;

        [self.ruleCountButton setTitle:[NSString stringWithFormat:@"%lu %@", (unsigned long) [self.analysis.rules count],
                                                 NSLocalizedString(@"RULES", nil)]
                              forState:UIControlStateNormal];

        if ([self.analysis.emptyParamCount integerValue] > 0) {
            [self.emptyRulesLabel removeConstraint:self.collapseEmptyRulesConstraint];
        }
        else {
            [self.emptyRulesLabel addConstraint:self.collapseEmptyRulesConstraint];
        }
    }
}

@end
