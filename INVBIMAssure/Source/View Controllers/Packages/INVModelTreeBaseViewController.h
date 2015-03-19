//
//  INVModelTreeBaseViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"
#import "INVModelTreeNode.h"

#define CONTEXT_NODE_LEVEL(n) ((void *) (n))

#define NODE_LEVEL_ROOT CONTEXT_NODE_LEVEL(0)
#define NODE_LEVEL_CATEGORY CONTEXT_NODE_LEVEL(1)
#define NODE_LEVEL_ELEMENT CONTEXT_NODE_LEVEL(2)

@interface INVModelTreeBaseViewController : INVCustomTableViewController

- (void)reloadData:(NSNumber *)animated;

#pragma mark - Override in subclass
- (INVModelTreeNode *)rootNode;
- (IBAction)onModelTreeNodeDetailsSelected:(id)sender;

@end
