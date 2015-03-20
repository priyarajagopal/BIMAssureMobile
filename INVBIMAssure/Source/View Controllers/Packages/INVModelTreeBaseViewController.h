//
//  INVModelTreeBaseViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"
#import "INVModelTreeNode.h"

@interface INVModelTreeBaseViewController : INVCustomTableViewController

- (void)reloadData:(NSNumber *)animated;
- (void)registerNode:(INVModelTreeNode *)node animateChanges:(BOOL)animated;

#pragma mark - Override in subclass
- (INVModelTreeNode *)rootNode;
- (IBAction)onModelTreeNodeDetailsSelected:(id)sender;

@end
