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

@property (nonatomic,copy) NSNumber* projectId;
@property (nonatomic,copy) NSNumber* ruleSetId;
@end
