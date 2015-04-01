//
//  INVModelTreeTableViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"
#import "INVModelTreeBaseViewController.h"

@interface INVModelTreeBuildingElementsTableViewController : INVModelTreeBaseViewController

@property NSNumber *projectId;
@property NSNumber *packageMasterId;
@property NSNumber *packageVersionId;

@end
