//
//  INVFileRuleSetListTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVFileRuleSetListTableViewController : INVCustomTableViewController
@property (nonatomic,assign) BOOL showRuleSetsForFileId;
@property (nonatomic,assign) NSNumber* projectId;
@property (nonatomic,assign) NSNumber* fileId;

-(void)resetRuleSetEntries;
@end