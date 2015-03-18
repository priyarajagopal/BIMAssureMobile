//
//  INVAnalysisRulesTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/18/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisRulesTableViewController.h"
#import "INVRuleDefinitionsTableViewController.h"

@implementation INVAnalysisRulesTableViewController

#pragma mark - View Lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRuleDefinitions"]) {
        INVRuleDefinitionsTableViewController *ruleDefinitionsVC = [segue destinationViewController];
        ruleDefinitionsVC.analysisId = self.analysisId;
    }
}

@end
