//
//  INVModelTreeTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeBuildingElementsTableViewController.h"
#import "INVBuildingElementPropertiesTableViewController.h"
#import "INVModelViewerContainerViewController.h"

#import "NSArray+INVCustomizations.h"
#import "UIView+INVCustomizations.h"
#import "NSObject+INVCustomizations.h"

#import "INVModelTreeNode.h"
#import "INVModelTreeNodeTableViewCell.h"

#import "INVMutableSectionedArray.h"
#import <AWPagedArray/AWPagedArray.h>

@interface INVModelTreeBuildingElementsTableViewController ()

@property (nonatomic, readwrite) INVModelTreeNode *rootNode;

@end

@implementation INVModelTreeBuildingElementsTableViewController

#pragma - Content Management

- (INVModelTreeNode *)treeNodeForElement:(NSString *)elementId
                   withBuildingElementId:(NSNumber *)buildingElementId
                         withDisplayName:(NSString *)displayName
                               andParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode treeNodeWithName:displayName id:elementId andLoadingBlock:nil];
    node.buildingElementId = buildingElementId;
    node.parent = parent;

    return node;
}

- (INVModelTreeNode *)treeNodeForCategory:(NSString *)category withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode
        treeNodeWithName:category
                      id:@([category hash])
         andLoadingBlock:^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
                             NSError *__strong *errorPtr, void (^completed)(NSArray *) ) {
             [self.globalDataManager.invServerClient
                 fetchBuildingElementOfSpecifiedCategoryWithDisplayname:node.name
                                                    ForPackageVersionId:self.packageVersionId
                                                             fromOffset:@(range.location)
                                                               withSize:@(range.length)
                                                    withCompletionBlock:^(id searchResult, INVEmpireMobileError *error) {
                                                        if (error) {
                                                            *errorPtr = [NSError
                                                                errorWithDomain:INVEmpireMobileErrorDomain
                                                                           code:error.code.integerValue
                                                                       userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                                            completed(nil);

                                                            return;
                                                        }

                                                        NSArray *hits = [searchResult valueForKeyPath:@"hits"];

                                                        NSArray *ids = [hits valueForKeyPath:@"_id"];

                                                        NSArray *names = [[[hits valueForKey:@"fields"]
                                                            valueForKey:@"intrinsics.name.value"]
                                                            valueForKeyPath:@"@unionOfArrays.self"];

                                                        NSArray *buildingElementIds =
                                                            [[[hits valueForKey:@"fields"] valueForKey:@"system.id"]
                                                                valueForKeyPath:@"@unionOfArrays.self"];

                                                        *expectedTotalCount =
                                                            [[searchResult valueForKeyPath:@"total"] integerValue];

                                                        NSMutableArray *children = [NSMutableArray new];

                                                        [ids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                            [children
                                                                addObject:[self treeNodeForElement:obj
                                                                              withBuildingElementId:buildingElementIds[idx]
                                                                                    withDisplayName:names[idx]
                                                                                          andParent:node]];

                                                        }];

                                                        completed(children);
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
                     fetchBuildingElementCategoriesForPackageVersionId:self.packageVersionId
                                                   withCompletionBlock:^(id searchResult, INVEmpireMobileError *error) {
                                                       if (error) {
                                                           *errorPtr = [NSError
                                                               errorWithDomain:INVEmpireMobileErrorDomain
                                                                          code:error.code.integerValue
                                                                      userInfo:@{NSLocalizedDescriptionKey : error.message}];

                                                           completed(nil);
                                                           return;
                                                       }

                                                       NSArray *categories =
                                                           [searchResult valueForKeyPath:@"aggregations.category.buckets.key"];

                                                       *expectedTotalCount = [categories count];

                                                       completed([categories
                                                           arrayByApplyingBlock:^id(id obj, NSUInteger _, BOOL *__) {
                                                               return [self treeNodeForCategory:obj withParent:node];
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
