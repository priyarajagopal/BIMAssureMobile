//
//  INVRuleIssuesTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 3/30/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"
#import "INVBlackTintedTableViewController.h"

@interface INVRuleIssuesTableViewController : INVBlackTintedTableViewController

@property (nonatomic, copy) NSNumber *projectId;
@property (nonatomic, copy) INVAnalysisRunResult *ruleResult;
@property (nonatomic, copy) NSNumber *buildingElementId;
@end
