//
//  INVModelTreeIssuesTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeIssuesTableViewController.h"
#import "NSObject+INVCustomizations.h"

@interface INVModelTreeIssuesTableViewController ()

@property (nonatomic, readwrite) INVModelTreeNode *rootNode;

@end

@implementation INVModelTreeIssuesTableViewController

- (INVModelTreeNode *)rootNode
{
    if (_rootNode == nil) {
        _rootNode = [INVModelTreeNode
            treeNodeWithName:nil
                          id:nil
             andLoadingBlock:^NSArray *(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount) {
                 dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
                 __block NSArray *childNodes = nil;

                 [self.globalDataManager.invServerClient
                     getAnalysisMembershipForPkgMaster:self.packageVersionId
                                   WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                       INVLogDebug(@"%@", result);
                                   }];

                 dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_FOREVER);
                 *expectedTotalCount = [childNodes count];

                 return childNodes;
             }];

        [_rootNode addObserver:self forKeyPath:@"children" options:NSKeyValueObservingOptionPrior context:NODE_LEVEL_ROOT];

        __weak typeof(self) weakSelf = self;
        [_rootNode addDeallocHandler:^(id rootNode) {
            [rootNode removeObserver:weakSelf forKeyPath:@"children"];
        }];
    }

    return _rootNode;
}

@end
