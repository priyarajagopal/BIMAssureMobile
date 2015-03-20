//
//  INVAnalysisRunCollectionViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/20/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisRunCollectionViewCell.h"
#import "UILabel+INVCustomizations.h"
#import "UIFont+INVCustomizations.h"

@interface INVAnalysisRunCollectionViewCell ()

@property IBOutlet UILabel *analysisNameLabel;
@property IBOutlet UILabel *analysisOverviewLabel;
@property IBOutlet UILabel *analysisIssueCountLabel;

@property IBOutlet UILabel *ruleCountLabel;
@property IBOutlet UIButton *showAnalysisButton;

@end

@implementation INVAnalysisRunCollectionViewCell

- (void)setAnalysis:(INVAnalysis *)analysis
{
    _analysis = analysis;

    [self setNeedsLayout];
}

- (void)setRun:(INVAnalysisRun *)run
{
    _run = run;

    [self setNeedsLayout];
}

- (void)setRunResults:(INVAnalysisRunResultsArray)runResults
{
    _runResults = runResults;

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [self.analysisNameLabel setText:self.analysis.name
                        withDefault:NSLocalizedString(@"ANALYSIS_NAME_UNAVAILABLE", nil)
                      andAttributes:@{NSFontAttributeName : self.analysisNameLabel.font.italicFont}];

    [self.analysisOverviewLabel setText:self.analysis.overview
                            withDefault:NSLocalizedString(@"ANALYSIS_OVERVIEW_UNAVAILABLE", nil)
                          andAttributes:@{NSFontAttributeName : self.analysisOverviewLabel.font.italicFont}];

    self.analysisIssueCountLabel.text = [[self.runResults valueForKeyPath:@"@count.issues"] stringValue];

    [super layoutSubviews];
}

@end
