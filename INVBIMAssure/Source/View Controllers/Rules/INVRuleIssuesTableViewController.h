//
//  INVRuleIssuesTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 3/30/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVRuleIssuesTableViewController : INVCustomTableViewController
@property (nonatomic, copy) INVAnalysisRunResult *ruleResult;
@property (nonatomic, copy) NSNumber *buildingElementId;
@end
