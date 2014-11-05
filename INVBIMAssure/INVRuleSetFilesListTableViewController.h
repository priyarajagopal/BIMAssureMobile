//
//  INVRuleSetIncludedFilesViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVRuleSetFilesListTableViewController : INVCustomTableViewController
@property (nonatomic,assign) BOOL showFilesForRuleSetId;
@property (nonatomic,assign) NSNumber* projectId;
@property (nonatomic,assign) NSNumber* ruleSetId;
@end
