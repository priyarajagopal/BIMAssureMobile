//
//  INVAnalysisEditViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/17/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVAnalysisEditViewController : INVCustomTableViewController

@property NSNumber *projectId;
@property (nonatomic) INVAnalysis *analysis;

@end
