//
//  INVRulesListViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVRulesListViewController : INVCustomTableViewController
@property (nonatomic,copy)NSNumber* projectId;

-(IBAction)done:(UIStoryboardSegue*) segue;
@end
