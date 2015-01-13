//
//  INVRunRulesTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVRunRulesTableViewController : INVCustomTableViewController
@property (nonatomic,copy)NSNumber* projectId;
@property (nonatomic,copy)NSNumber* fileVersionId;
@property (nonatomic,copy)NSNumber* fileMasterId;
@property (weak, nonatomic) IBOutlet UIButton *runRulesButton;
@property (nonatomic,copy)NSNumber* modelId;
- (IBAction)onRunRulesSelected:(UIButton *)sender;

@end
