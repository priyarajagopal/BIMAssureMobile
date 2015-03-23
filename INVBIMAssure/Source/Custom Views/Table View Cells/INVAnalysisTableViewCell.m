//
//  INVAnalysisTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisTableViewCell.h"

#import "UIFont+INVCustomizations.h"
#import "UILabel+INVCustomizations.h"

@interface INVAnalysisTableViewCell ()

@property IBOutlet UILabel *analysisNameLabel;
@property IBOutlet UILabel *analysisDescriptionLabel;
@property IBOutlet UIButton *ruleCountButton;

@property IBOutlet UIButton *editButton;
@property IBOutlet UIButton *rulesButton;
@property IBOutlet UIButton *runButton;
@property IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *packagesButton;

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
        [self.analysisNameLabel setText:self.analysis.name
                            withDefault:@"ANALYSIS_NAME_UNAVAILABLE"
                          andAttributes:@{NSFontAttributeName : [self.analysisNameLabel.font italicFont]}];

        [self.analysisDescriptionLabel setText:self.analysis.overview
                                   withDefault:@"ANALYSIS_DESCRIPTION_UNAVAILABLE"
                                 andAttributes:@{NSFontAttributeName : [self.analysisDescriptionLabel.font italicFont]}];

        [self.ruleCountButton setTitle:[NSString stringWithFormat:@"%lu %@", (unsigned long) [self.analysis.rules count],
                                                 NSLocalizedString(@"RULES", nil)]
                              forState:UIControlStateNormal];

        self.runButton.enabled = (self.analysis.rules.count > 0);

        if ([self.analysis.emptyParamCount integerValue] > 0) {
            [self.emptyRulesLabel removeConstraint:self.collapseEmptyRulesConstraint];
        }
        else {
            [self.emptyRulesLabel addConstraint:self.collapseEmptyRulesConstraint];
        }
    }
}

@end
