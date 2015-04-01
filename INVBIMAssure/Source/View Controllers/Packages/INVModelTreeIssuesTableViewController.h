//
//  INVModelTreeIssuesTableViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"
#import "INVModelTreeBaseViewController.h"

extern NSString *const INVModelTreeBuildingElementsElmentIdKey;
extern NSString *const INVModelTreeIssueRunKey;
extern NSString *const INVModelTreeIssueRunResultKey;

@interface INVModelTreeIssuesTableViewController : INVModelTreeBaseViewController

@property NSNumber *projectId;
@property NSNumber *packageMasterId;
@property NSNumber *packageVersionId;

@property (nonatomic, copy) INVAnalysisRunResult *runResult;
@property NSNumber *analysisRunId;

@property (assign) BOOL doNotClearBackground;
@end
