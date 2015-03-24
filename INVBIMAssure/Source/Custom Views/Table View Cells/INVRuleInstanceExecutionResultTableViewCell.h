//
//  INVRuleInstanceExecutionResultTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVRuleInstanceExecutionResultTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceName;
@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceExecutionDate;
@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceOverview;
@property (weak, nonatomic) IBOutlet UILabel *numIssues;
@property (weak, nonatomic) IBOutlet UILabel *executionStatus;
@property (weak, nonatomic) IBOutlet UILabel *alertIconLabel;
@property (copy, nonatomic) NSArray *associatedBuildingElementsWithIssues;
@property (copy, nonatomic) INVAnalysisRunResult* runResult;
@end
