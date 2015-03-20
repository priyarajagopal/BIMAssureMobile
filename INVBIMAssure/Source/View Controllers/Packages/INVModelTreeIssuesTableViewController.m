//
//  INVModelTreeIssuesTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeIssuesTableViewController.h"
#import "NSObject+INVCustomizations.h"
#import "NSArray+INVCustomizations.h"

@interface INVModelTreeIssuesTableViewController ()

@property (nonatomic, readwrite) INVModelTreeNode *rootNode;

@end

@implementation INVModelTreeIssuesTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    CGFloat imageSize = 25;
    self.tabBarItem.image = [[FAKFontAwesome warningIconWithSize:imageSize] imageWithSize:CGSizeMake(imageSize, imageSize)];
}

- (INVModelTreeNode *)treeNodeForIssue:(id)issue withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode treeNodeWithName:@"Issue" id:nil andLoadingBlock:nil];
    node.parent = parent;

    return node;
}

- (INVModelTreeNode *)treeNodeForAnalysisRun:(INVAnalysisRunResult *)runResult withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node =
        [INVModelTreeNode treeNodeWithName:runResult.status
                                        id:nil
                           andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                                               NSError *__strong *error, void (^completed)(NSArray *) ) {
                               *expectedTotalCount = [runResult.issues count];

                               completed([runResult.issues arrayByApplyingBlock:^id(id issue, NSUInteger _, BOOL *__) {
                                   return [self treeNodeForIssue:issue withParent:parent];
                               }]);

                               return YES;
                           }];

    node.parent = parent;

    [self registerNode:node animateChanges:YES];

    return node;
}

- (INVModelTreeNode *)treeNodeForAnalysis:(INVAnalysis *)analysis withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode
        treeNodeWithName:analysis.name
                      id:analysis.analysisId
         andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                             NSError *__strong *errorPtr, void (^completed)(NSArray *) ) {
             [self.globalDataManager.invServerClient
                 getAnalysisRunsForAnalysis:node.id
                        WithCompletionBlock:^(NSArray *result, INVEmpireMobileError *error) {
                            if (error) {
                                *errorPtr = [NSError errorWithDomain:INVEmpireMobileErrorDomain
                                                                code:error.code.integerValue
                                                            userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                completed(nil);
                                return;
                            }

                            INVLogDebug(@"%@", result);
                            *expectedTotalCount = [result count];

                            completed([result arrayByApplyingBlock:^(INVAnalysisRunResult *runResult, NSUInteger _, BOOL *__) {
                                return [self treeNodeForAnalysisRun:runResult withParent:node];
                            }]);
                        }];

             return YES;
         }];

    node.parent = parent;

    [self registerNode:node animateChanges:YES];

    return node;
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
                                   WithCompletionBlock:^(NSArray *result, INVEmpireMobileError *error) {
                                       if (error) {
                                           *errorPtr = [NSError errorWithDomain:INVEmpireMobileErrorDomain
                                                                           code:error.code.integerValue
                                                                       userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                           completed(nil);
                                           return;
                                       }

                                       INVLogDebug(@"%@", result);
                                       *expectedTotalCount = [result count];

                                       completed([result arrayByApplyingBlock:^(INVAnalysis *analysis, NSUInteger _, BOOL *__) {
                                           return [self treeNodeForAnalysis:analysis withParent:node];
                                       }]);
                                   }];

                 return YES;
             }];

        [self registerNode:_rootNode animateChanges:NO];
    }

    return _rootNode;
}

@end
