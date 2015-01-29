//
//  INVSplitViewControllerAggregateDelegate.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/27/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVSplitViewControllerAggregateDelegate : NSObject<UISplitViewControllerDelegate>

@property (nonatomic, weak) UISplitViewController *splitViewController;

- (void)addDelegate:(id<UISplitViewControllerDelegate>)delegate;
- (void)removeDelegate:(id<UISplitViewControllerDelegate>)delegate;

@end
