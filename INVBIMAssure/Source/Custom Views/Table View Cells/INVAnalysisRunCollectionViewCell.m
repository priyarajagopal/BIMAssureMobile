//
//  INVAnalysisRunCollectionViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/20/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisRunCollectionViewCell.h"
#import "UILabel+INVCustomizations.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+INVCustomizations.h"

@interface INVAnalysisRunCollectionViewCell ()

@property IBOutlet UILabel *analysisNameLabel;
@property IBOutlet UILabel *analysisOverviewLabel;
@property IBOutlet UILabel *analysisIssueCountLabel;
@property IBOutlet UILabel *analysisIssuesLabel;

@property IBOutlet UILabel *ruleCountLabel;
@property IBOutlet UIButton *showAnalysisButton;

@property (weak, nonatomic) IBOutlet UIView *theView;

@end

@implementation INVAnalysisRunCollectionViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.analysisNameLabel setText:self.analysis.name
                        withDefault:NSLocalizedString(@"ANALYSIS_NAME_UNAVAILABLE", nil)
                      andAttributes:@{NSFontAttributeName : self.analysisNameLabel.font.italicFont}];

    [self.analysisOverviewLabel setText:self.analysis.overview
                            withDefault:NSLocalizedString(@"ANALYSIS_OVERVIEW_UNAVAILABLE", nil)
                          andAttributes:@{NSFontAttributeName : self.analysisOverviewLabel.font.italicFont}];

    self.ruleCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"NUM_RULES", nil), self.analysis.rules.count];

    if (self.result) {
        NSNumber *count = self.result.numIssues;

        self.analysisIssuesLabel.hidden = NO;
        self.analysisIssueCountLabel.text = [NSString stringWithFormat:@"%@", count];

        self.analysisIssueCountLabel.textColor = (count.integerValue ? [UIColor redColor] : [UIColor grayColor]);
    }
    else {
        self.analysisIssuesLabel.hidden = YES;
        self.analysisIssueCountLabel.text = NSLocalizedString(@"NOT_RUN", nil);
        self.analysisIssueCountLabel.textColor = [UIColor grayColor];

        self.showAnalysisButton.hidden = YES;
    }
}

@end
