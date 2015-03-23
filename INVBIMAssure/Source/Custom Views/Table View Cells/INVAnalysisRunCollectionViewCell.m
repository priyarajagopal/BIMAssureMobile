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

@property IBOutlet UILabel *ruleCountLabel;
@property IBOutlet UIButton *showAnalysisButton;
@property (nonatomic, assign) BOOL didAnalysisChange;
@property (weak, nonatomic) IBOutlet UIView *theView;
- (IBAction)showAnalysisRun:(UIButton *)sender;

@end

@implementation INVAnalysisRunCollectionViewCell

- (void)setAnalysis:(INVAnalysis *)analysis
{
    _analysis = analysis;
    self.didAnalysisChange = YES;
 
    [self setNeedsLayout];
}

- (void)setResult:(INVAnalysisRunResultsArray)result
{
    _result = result;

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if (self.didAnalysisChange) {
        [self.analysisNameLabel setText:self.analysis.name
                            withDefault:NSLocalizedString(@"ANALYSIS_NAME_UNAVAILABLE", nil)
                          andAttributes:@{NSFontAttributeName : self.analysisNameLabel.font.italicFont}];

        [self.analysisOverviewLabel setText:self.analysis.overview
                                withDefault:NSLocalizedString(@"ANALYSIS_OVERVIEW_UNAVAILABLE", nil)
                              andAttributes:@{NSFontAttributeName : self.analysisOverviewLabel.font.italicFont}];
        self.didAnalysisChange = NO;
    }
    else {
        NSInteger count = 0;
        for (INVAnalysisRunResult *resultVal in self.result) {
            count += resultVal.issues.count;
        }
        self.analysisIssueCountLabel.text = [NSString stringWithFormat:@"%ld", count];

        NSInteger ruleCount = self.result.count;
        self.ruleCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"NUM_RULES", nil), ruleCount];
    }
   
    [super layoutSubviews];
}



@end
