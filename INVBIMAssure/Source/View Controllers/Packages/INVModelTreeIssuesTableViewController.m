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

- (void)awakeFromNib
{
    [super awakeFromNib];

    CGFloat imageSize = 25 * UIScreen.mainScreen.scale;
    self.tabBarItem.image = [[FAKFontAwesome warningIconWithSize:imageSize] imageWithSize:CGSizeMake(imageSize, imageSize)];
}

- (INVModelTreeNode *)rootNode
{
    if (_rootNode == nil) {
        _rootNode = [INVModelTreeNode
            treeNodeWithName:NSStringFromClass([self class])
                          id:nil
             andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                                 NSError *__strong *errorPtr, void (^completed)(NSArray *) ) {
                 [self.globalDataManager.invServerClient
                     getAnalysisMembershipForPkgMaster:self.packageVersionId
                                   WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                       if (error) {
                                           *errorPtr = [NSError errorWithDomain:INVEmpireMobileErrorDomain
                                                                           code:error.code.integerValue
                                                                       userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                           completed(nil);
                                           return;
                                       }

                                       INVLogDebug(@"%@", result);
                                   }];

                 return YES;
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
