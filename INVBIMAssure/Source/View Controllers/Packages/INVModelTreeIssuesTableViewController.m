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
#import "INVBuildingElementPropertiesTableViewController.h"

#import "UIView+INVCustomizations.h"
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

- (INVModelTreeNode *)treeNodeForBuildingElement:(NSDictionary *)buildingElement withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node =
        [INVModelTreeNode treeNodeWithName:[buildingElement valueForKeyPath:@"_source.intrinsics.name.display"]
                                        id:buildingElement[@"_id"]
                           andLoadingBlock:nil];

    node.buildingElementId = [buildingElement valueForKeyPath:@"_source.system.id"];
    node.parent = parent;
    [self registerNode:node animateChanges:YES];

    return node;
}

- (INVModelTreeNode *)treeNodeForIssue:(NSDictionary *)issue withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode
        treeNodeWithName:issue[@"description"]
                      id:issue[@"id"]
         andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                             NSError *__strong *errorPtr, void (^completed)(NSArray *) ) {
             [self.globalDataManager.invServerClient
                 fetchBuildingElementDetailsForIssue:issue[@"id"]
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

- (INVModelTreeNode *)treeNodeForAnalysisRunDetails:(INVAnalysisRunDetails *)result withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node =
        [INVModelTreeNode treeNodeWithName:[NSString stringWithFormat:@"Run Details %@", result.analysisRunDetailsId]
                                        id:result.analysisRunDetailsId
                           andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                                               NSError *__strong *error, void (^completed)(NSArray *) ) {

                               NSArray *issues = [result.runDetails valueForKeyPath:@"@unionOfArrays.issues"];
                               *expectedTotalCount = [issues count];
                               completed([issues arrayByApplyingBlock:^id(id issue, NSUInteger _, BOOL *__) {
                                   return [self treeNodeForIssue:issue withParent:node];
                               }]);

                               return YES;
                           }];

    node.parent = parent;
    node.expanded = YES;

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
                     getAnalysisRunResultsForPkgVersion:self.packageVersionId
                                    WithCompletionBlock:^(INVAnalysisRunDetailsArray analysisDetails,
                                                            INVEmpireMobileError *error) {
                                        if (error) {
                                            *errorPtr = [NSError errorWithDomain:INVEmpireMobileErrorDomain
                                                                            code:error.code.integerValue
                                                                        userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                            completed(nil);
                                            return;
                                        }

                                        /*
                                        analysisDetails = [analysisDetails
                                            filteredArrayUsingPredicate:
                                                [NSPredicate predicateWithBlock:^BOOL(INVAnalysisRunDetails *details,
                                                                                    NSDictionary *bindings) {
                                                    return [details.runDetails
                                                               indexOfObjectPassingTest:^BOOL(INVAnalysisRunResult *run,
                                                                                            NSUInteger idx, BOOL *stop) {
                                                                   return run.issues.count > 0;
                                                               }] != NSNotFound;
                                                }]];
                                        */

                                        *expectedTotalCount = [analysisDetails count];
                                        completed([analysisDetails
                                            arrayByApplyingBlock:^id(INVAnalysisRunDetails *details, NSUInteger _, BOOL *__) {
                                                return [self treeNodeForAnalysisRunDetails:details withParent:node];
                                            }]);
                                    }];

                 return YES;
             }];

        [self registerNode:_rootNode animateChanges:NO];
    }

    return _rootNode;
}

#pragma mark - IBActions

- (void)onModelTreeNodeDetailsSelected:(id)sender
{
    INVModelTreeNodeTableViewCell *cell = [sender findSuperviewOfClass:[INVModelTreeNodeTableViewCell class] predicate:nil];
    INVModelTreeNode *node = cell.node;

    UINavigationController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"ViewPropertiesNC"];

    INVBuildingElementPropertiesTableViewController *propertiesViewController =
        (INVBuildingElementPropertiesTableViewController *) [viewController topViewController];
    propertiesViewController.packageVersionId = self.packageVersionId;
    propertiesViewController.buildingElementCategory = node.parent.name;
    propertiesViewController.buildingElementName = node.name;
    propertiesViewController.buildingElementId = node.id;

    viewController.modalPresentationStyle = UIModalPresentationPopover;

    [self presentViewController:viewController animated:YES completion:nil];

    viewController.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];

    // This should be the accessory button.
    UIView *anchor = sender;

    viewController.popoverPresentationController.sourceView = anchor;
    viewController.popoverPresentationController.sourceRect = [anchor bounds];
    viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionLeft;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    INVModelTreeNodeTableViewCell *cell = (INVModelTreeNodeTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];

    [(INVModelViewerContainerViewController *) self.parentViewController.parentViewController
        highlightElement:cell.node.buildingElementId];

    if (!cell.node.isLeaf) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
