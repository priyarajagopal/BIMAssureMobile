//
//  INVRuleDefinitionsTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/25/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INVCustomTableViewController.h"
#import "INVRuleInstanceTableViewController.h"

@interface INVRuleDefinitionsTableViewController : INVCustomTableViewController
@property (nonatomic, copy) NSNumber *ruleSetId;
@property (nonatomic, weak) id<INVRuleInstanceTableViewControllerDelegate> createRuleInstanceDelegate;
@end
