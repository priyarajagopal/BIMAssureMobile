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

static NSString *const INVModelTreeBuildingElementsElmentIdKey = @"buildingElement";
static NSString *const INVModelTreeBuildingElementsModelIdKey = @"modelId";

@interface INVModelTreeBuildingElementsTableViewController ()

@property (nonatomic, readwrite) INVModelTreeNode *rootNode;

@end

@implementation INVModelTreeBuildingElementsTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    CGFloat imageSize = 25;
    self.tabBarItem.image = [[FAKFontAwesome sitemapIconWithSize:imageSize] imageWithSize:CGSizeMake(imageSize, imageSize)];
}

#pragma - Content Management

- (INVModelTreeNode *)treeNodeForElement:(NSString *)elementId
                             withModelId:(NSNumber *)modelId
                         withDisplayName:(NSString *)displayName
                               andParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode treeNodeWithName:displayName
                                                       userInfo:@{
                                                           INVModelTreeBuildingElementsModelIdKey : modelId,
                                                           INVModelTreeBuildingElementsElmentIdKey : elementId
                                                       }
                                                andLoadingBlock:nil];
    node.parent = parent;

    return node;
}

- (INVModelTreeNode *)treeNodeForCategory:(NSString *)category withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode
        treeNodeWithName:category
                userInfo:nil
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

                                                        NSArray *names =
                                                            [[[hits valueForKey:@"fields"] valueForKey:@"intrinsics.name.value"]
                                                                valueForKeyPath:@"@unionOfArrays.self"];

                                                        NSArray *modelIds =
                                                            [[[hits valueForKey:@"fields"] valueForKey:@"system.id"]
                                                                valueForKeyPath:@"@unionOfArrays.self"];

                                                        *expectedTotalCount =
                                                            [[searchResult valueForKeyPath:@"total"] integerValue];

                                                        NSMutableArray *children = [NSMutableArray new];

                                                        [ids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                            [children addObject:[self treeNodeForElement:obj
                                                                                             withModelId:modelIds[idx]
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
                    userInfo:nil
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
    propertiesViewController.buildingElementId = node.userInfo[INVModelTreeBuildingElementsElmentIdKey];

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

    INVModelViewerContainerViewController *modelViewerContainer =
        (INVModelViewerContainerViewController *) [self.navigationController topViewController];
    [modelViewerContainer highlightElement:cell.node.userInfo[INVModelTreeBuildingElementsModelIdKey]];

    if (!cell.node.isLeaf) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
