//
//  INVRuleSetFilesTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVRuleSetManageFilesContainerViewController : INVCustomViewController
- (IBAction)onResetTapped:(UIBarButtonItem *)sender;

@property (nonatomic,strong) NSNumber* projectId;
@property (nonatomic,assign) NSNumber* ruleSetId;
@end
