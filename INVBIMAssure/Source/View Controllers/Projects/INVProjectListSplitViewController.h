//
//  INVProjectListSplitViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomSplitViewController.h"
#import "INVSplitViewControllerAggregateDelegate.h"

@interface INVProjectListSplitViewController : INVCustomSplitViewController

@property (nonatomic, copy) NSNumber *accountId;
@property (nonatomic) INVSplitViewControllerAggregateDelegate *aggregateDelegate;

- (void)setSelectedProject:(INVProject *)project;

@end
