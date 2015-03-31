//
//  INVModelTreeIssuesTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeIssuesTableViewController.h"
#import "INVModelViewerContainerViewController.h"
#import "INVModelTreeNodeTableViewCell.h"
#import "INVRuleIssuesTableViewController.h"

#import "UIView+INVCustomizations.h"
#import "NSObject+INVCustomizations.h"
#import "NSArray+INVCustomizations.h"

static NSString *const INVModelTreeBuildingElementsElmentIdKey = @"buildingElement";
static NSString *const INVModelTreeIssueRuleResultKey = @"ruleResult";

@interface INVModelTreeIssuesTableViewController ()

@property (nonatomic, readwrite) INVModelTreeNode *rootNode;

@end

@implementation INVModelTreeIssuesTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    CGFloat imageSize = 25;
    self.tabBarItem.image = [[FAKFontAwesome warningIconWithSize:imageSize] imageWithSize:CGSizeMake(imageSize, imageSize)];

    if (self.doNotClearBackground) {
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - Content Management

- (INVModelTreeNode *)treeNodeForBuildingElement:(NSDictionary *)buildingElement withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode
        treeNodeWithName:[buildingElement valueForKeyPath:@"_source.intrinsics.name.value"]
                userInfo:@{
                    INVModelTreeBuildingElementsElmentIdKey : [buildingElement valueForKeyPath:@"_source.system.id"]
                }
         andLoadingBlock:nil];

    node.parent = parent;

    [self registerNode:node animateChanges:YES];

    return node;
}

- (INVModelTreeNode *)treeNodeForIssue:(INVRuleIssue *)issue withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode
        treeNodeWithName:issue.issueDescription
                userInfo:nil
         andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                             NSError *__strong *errorPtr, void (^completed)(NSArray *) ) {
             [self.globalDataManager.invServerClient
                 fetchBuildingElementDetailsForIssue:issue.issueId
                                 withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                     if (error) {
                                         *errorPtr = [NSError errorWithDomain:INVEmpireMobileErrorDomain
                                                                         code:error.code.integerValue
                                                                     userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                         completed(nil);
                                         return;
                                     }

                                     *expectedTotalCount = [result count];
                                     completed([result arrayByApplyingBlock:^id(id buildingElement, NSUInteger _, BOOL *__) {
                                         return [self treeNodeForBuildingElement:buildingElement withParent:node];
                                     }]);
                                 }];

             return YES;
         }];

    node.parent = parent;
    [self registerNode:node animateChanges:YES];

    return node;
}

- (INVModelTreeNode *)treeNodeForAnalysisRunResult:(INVAnalysisRunResult *)runResult withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode
        treeNodeWithName:runResult.ruleDescription
                userInfo:@{
                    INVModelTreeIssueRuleResultKey : runResult,
                    INVModelTreeNodeShowsDetailsKey : @YES
                }
         andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                             NSError *__strong *errorPtr, void (^completed)(NSArray *) ) {
             [self.globalDataManager.invServerClient
                 fetchBuildingElementDetailsForRunResult:runResult.analysisRunResultId
                                     withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                         if (error) {
                                             *errorPtr =
                                                 [NSError errorWithDomain:INVEmpireMobileErrorDomain
                                                                     code:error.code.integerValue
                                                                 userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                             completed(nil);
                                             return;
                                         }

                                         *expectedTotalCount = [result count];
                                         completed(
                                             [result arrayByApplyingBlock:^id(id buildingElement, NSUInteger _, BOOL *__) {
                                                 return [self treeNodeForBuildingElement:buildingElement withParent:node];
                                             }]);
                                     }];

             return YES;
         }];

    node.parent = parent;

    [self registerNode:node animateChanges:YES];

    return node;
}

- (INVModelTreeNode *)treeNodeForAnalysisRun:(INVAnalysisRun *)run withParent:(INVModelTreeNode *)parent
{
    INVAnalysis *analysis = [self analysisForId:run.analysisId];

    INVModelTreeNode *node = [INVModelTreeNode
        treeNodeWithName:analysis.name
                userInfo:@{
                    INVModelTreeNodeShowsExpandIndicatorKey : @NO
                }
         andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                             NSError *__strong *errorPtr, void (^completed)(NSArray *) ) {
             [self.globalDataManager.invServerClient
                 getExecutionResultsForAnalysisRun:run.analysisRunId
                               WithCompletionBlock:^(INVAnalysisRunResultsArray results, INVEmpireMobileError *error) {
                                   if (error) {
                                       *errorPtr = [NSError errorWithDomain:INVEmpireMobileErrorDomain
                                                                       code:error.code.integerValue
                                                                   userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                       completed(nil);
                                       return;
                                   }

                                   *expectedTotalCount = [results count];
                                   completed([results
                                       arrayByApplyingBlock:^id(INVAnalysisRunResult *runResult, NSUInteger _, BOOL *__) {
                                           return [self treeNodeForAnalysisRunResult:runResult withParent:node];
                                       }]);

                               }];

             return YES;
         }];

    if (analysis == nil) {
        [self.globalDataManager.invServerClient getAnalysesForId:run.analysisId
                                             withCompletionBlock:^(INVAnalysis *result, INVEmpireMobileError *error) {
                                                 node.name = [result name];

                                                 [self reloadData:@NO];
                                             }];
    }

    node.parent = parent;
    node.expanded = YES;

    [self registerNode:node animateChanges:YES];

    return node;
}

- (INVModelTreeNode *)rootNode
{
    if (_rootNode == nil) {
        if (self.runResult) {
            _rootNode = [self treeNodeForAnalysisRunResult:self.runResult withParent:nil];
        }
        else {
            _rootNode = [INVModelTreeNode
                treeNodeWithName:NSStringFromClass([self class])
                        userInfo:nil
                 andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                                     NSError *__strong *errorPtr, void (^completed)(NSArray *) ) {
                     [self.globalDataManager.invServerClient
                         getAnalysisRunResultsForPkgVersion:self.packageVersionId
                                        WithCompletionBlock:^(INVAnalysisRunArray analysisRuns, INVEmpireMobileError *error) {
                                            if (error) {
                                                *errorPtr =
                                                    [NSError errorWithDomain:INVEmpireMobileErrorDomain
                                                                        code:error.code.integerValue
                                                                    userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                                completed(nil);
                                                return;
                                            }

                                            *expectedTotalCount = [analysisRuns count];
                                            completed([analysisRuns
                                                arrayByApplyingBlock:^id(INVAnalysisRun *run, NSUInteger _, BOOL *__) {
                                                    return [self treeNodeForAnalysisRun:run withParent:node];
                                                }]);
                                        }];

                     return YES;
                 }];
        }

        [self registerNode:_rootNode animateChanges:NO];
    }

    return _rootNode;
}

- (INVAnalysis *)analysisForId:(NSNumber *)analysisId
{
    return [[self.globalDataManager.invServerClient.analysesManager analysesForIds:@[ analysisId ]] firstObject];
}

#pragma mark - IBActions

- (void)onModelTreeNodeDetailsSelected:(id)sender
{
    INVModelTreeNodeTableViewCell *cell = [sender findSuperviewOfClass:[INVModelTreeNodeTableViewCell class] predicate:nil];
    INVModelTreeNode *node = cell.node;

    UINavigationController *viewController =
        [[UIStoryboard storyboardWithName:@"Analyses" bundle:nil] instantiateViewControllerWithIdentifier:@"ruleIssuesNC"];

    INVRuleIssuesTableViewController *issuesViewController =
        (INVRuleIssuesTableViewController *) [viewController topViewController];

    issuesViewController.buildingElementId = node.userInfo[INVModelTreeBuildingElementsElmentIdKey];
    issuesViewController.ruleResult =
        node.userInfo[INVModelTreeIssueRuleResultKey] ?: node.parent.userInfo[INVModelTreeIssueRuleResultKey];

    viewController.modalPresentationStyle = UIModalPresentationPopover;

    [self presentViewController:viewController animated:YES completion:nil];

    viewController.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];

    // This should be the accessory button.
    UIView *anchor = sender;

    viewController.popoverPresentationController.sourceView = anchor;
    viewController.popoverPresentationController.sourceRect = [anchor bounds];
    viewController.popoverPresentationController.permittedArrowDirections =
        UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVModelTreeNodeTableViewCell *cell = (INVModelTreeNodeTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];

    if (!cell.node.isLeaf) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }

    if (cell.node.userInfo[INVModelTreeNodeShowsExpandIndicatorKey]) {
        return;
    }

    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    INVModelViewerContainerViewController *modelViewerController =
        (INVModelViewerContainerViewController *) [self.navigationController topViewController];
    [modelViewerController highlightElement:cell.node.userInfo[INVModelTreeBuildingElementsElmentIdKey]];
}

@end
