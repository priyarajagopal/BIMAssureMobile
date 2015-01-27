//
//  INVRuleInstanceTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@class INVRuleInstanceTableViewController;

@interface INVRuleInstanceTableViewController : INVCustomTableViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic,copy) NSString* ruleName;
@property (nonatomic,copy) NSNumber* ruleInstanceId;
@property (nonatomic,copy) NSNumber* ruleSetId;
@property (nonatomic,copy) NSNumber* ruleId;
@end
