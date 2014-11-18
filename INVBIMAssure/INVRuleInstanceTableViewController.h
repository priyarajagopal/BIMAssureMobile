//
//  INVRuleInstanceTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVRuleInstanceTableViewController : INVCustomTableViewController
- (IBAction)onEditRuleInstanceTapped:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic,assign) NSNumber* ruleInstanceId;
@property (nonatomic,assign) NSNumber* ruleSetId;
@end
