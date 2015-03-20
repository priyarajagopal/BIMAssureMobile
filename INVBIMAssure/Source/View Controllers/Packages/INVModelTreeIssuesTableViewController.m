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

- (INVModelTreeNode *)treeNodeForAnalysisRunResult:(INVAnalysisRunResult *)result withParent:(INVModelTreeNode *)parent
{
    return nil;
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
                     getAnalysisRunResultsForPkgVersion:self.packageVersionId
                                    WithCompletionBlock:^(INVAnalysisRunResultsArray analysisruns,
                                                            INVEmpireMobileError *error) {
                                        if (error) {
                                            *errorPtr = [NSError errorWithDomain:INVEmpireMobileErrorDomain
                                                                            code:error.code.integerValue
                                                                        userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                            completed(nil);
                                            return;
                                        }

                                        *expectedTotalCount = [analysisruns count];
                                        completed([analysisruns
                                            arrayByApplyingBlock:^id(INVAnalysisRunResult *result, NSUInteger _, BOOL *__) {
                                                return [self treeNodeForAnalysisRunResult:result withParent:node];
                                            }]);
                                    }];

                 return YES;
             }];

        [self registerNode:_rootNode animateChanges:NO];
    }

    return _rootNode;
}

@end
