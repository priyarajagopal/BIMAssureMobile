//
//  INVProjectsTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVProjectsTableViewController : INVCustomTableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bottomBarButtonItem;

- (void)setSelectedProject:(INVProject *)project;

@end
