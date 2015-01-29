//
//  INVRuleExecutionsTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/3/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVRuleExecutionsTableViewController : INVCustomTableViewController

@property (nonatomic, copy) NSNumber *projectId;
@property (nonatomic, copy) NSNumber *fileVersionId;
@property (nonatomic, copy) NSNumber *fileMasterId;
@property (nonatomic, copy) NSNumber *modelId;
@end
