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
@property (nonatomic,copy) NSNumber* projectId;
@property (nonatomic,copy) NSNumber* ruleSetId;

-(void)resetFileEntries;
@end
