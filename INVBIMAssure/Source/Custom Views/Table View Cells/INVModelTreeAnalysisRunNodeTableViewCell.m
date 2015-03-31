//
//  INVModelTreeAnalysisRunNodeTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/31/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeAnalysisRunNodeTableViewCell.h"
#import "INVModelTreeIssuesTableViewController.h"

@interface INVModelTreeAnalysisRunNodeTableViewCell ()

@property IBOutlet UILabel *analysisNameLabel;
@property IBOutlet UILabel *issueCountLabel;

@end

@implementation INVModelTreeAnalysisRunNodeTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateUI];
}

- (void)updateUI
{
    if ([self.node isKindOfClass:[NSNull class]]) {
        self.analysisNameLabel.text = nil;
        self.issueCountLabel.text = nil;
    }
    else {
        self.analysisNameLabel.text = self.node.name;

        INVAnalysisRun *analysisRun = self.node.userInfo[INVModelTreeIssueRunKey];
        self.issueCountLabel.text =
            [NSString stringWithFormat:NSLocalizedString(@"ANALYSIS_RUN_NODE_ISSUE_COUNT", nil), analysisRun.numIssues];
    }
}

- (INVAnalysis *)analysisForId:(NSNumber *)analysisId
{
    return [[[INVGlobalDataManager sharedInstance].invServerClient.analysesManager analysesForIds:@[ analysisId ]] firstObject];
}

@end
