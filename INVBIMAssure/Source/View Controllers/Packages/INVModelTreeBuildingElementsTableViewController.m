//
//  INVModelTreeTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeBuildingElementsTableViewController.h"
#import "INVBuildingElementPropertiesTableViewController.h"

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

- (void)setPackageVersionId:(NSNumber *)packageVersionId
{
    _packageVersionId = packageVersionId;
    _rootNode = nil;

    [self reloadData:@NO];
}

#pragma - Content Management

- (INVModelTreeNode *)treeNodeForElement:(NSNumber *)elementId
                         withDisplayName:(NSString *)displayName
                               andParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode treeNodeWithName:displayName id:elementId andLoadingBlock:nil];
    node.parent = parent;

    return node;
}

- (INVModelTreeNode *)treeNodeForCategory:(NSString *)category withParent:(INVModelTreeNode *)parent
{
    INVModelTreeNode *node = [INVModelTreeNode
        treeNodeWithName:category
                      id:@([category hash])
         andLoadingBlock:^NSArray *(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount) {
             dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
             __block NSArray *childNodes = nil;

             [self.globalDataManager.invServerClient
                 fetchBuildingElementOfSpecifiedCategoryWithDisplayname:node.name
                                                    ForPackageVersionId:self.packageVersionId
                                                             fromOffset:@(range.location)
                                                               withSize:@(range.length)
                                                    withCompletionBlock:^(id searchResult, INVEmpireMobileError *error) {
                                                        if (error) {
                                                            INVLogError(@"%@", error);
                                                            return;
                                                        }

                                                        NSArray *hits = [searchResult valueForKeyPath:@"hits"];
                                                        NSArray *ids = [hits valueForKeyPath:@"_id"];
                                                        NSArray *names = [[[hits valueForKey:@"fields"]
                                                            valueForKey:@"intrinsics.name.display"]
                                                            valueForKeyPath:@"@unionOfArrays.self"];

                                                        *expectedTotalCount =
                                                            [[searchResult valueForKeyPath:@"total"] integerValue];

                                                        NSDictionary *elements =
                                                            [[NSDictionary alloc] initWithObjects:names forKeys:ids];

                                                        NSMutableArray *children = [NSMutableArray new];

                                                        [elements
                                                            enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                                                [children addObject:[self treeNodeForElement:key
                                                                                             withDisplayName:obj
                                                                                                   andParent:node]];

                                                            }];

                                                        childNodes = children;

                                                        dispatch_semaphore_signal(waitSemaphore);
                                                    }];

             dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_FOREVER);

             return childNodes;
         }];

    node.parent = parent;

    [node addObserver:self forKeyPath:@"children" options:NSKeyValueObservingOptionPrior context:NODE_LEVEL_CATEGORY];
    [node addDeallocHandler:^(id node) {
        [node removeObserver:self forKeyPath:@"children"];
    }];

    return node;
}

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
                     fetchBuildingElementCategoriesForPackageVersionId:self.packageVersionId
                                                   withCompletionBlock:^(id searchResult, INVEmpireMobileError *error) {
                                                       if (error) {
                                                           INVLogError(@"%@", error);

                                                           dispatch_semaphore_signal(waitSemaphore);
                                                           return;
                                                       }

                                                       NSArray *categories =
                                                           [searchResult valueForKeyPath:@"aggregations.category.buckets.key"];

                                                       childNodes = [categories
                                                           arrayByApplyingBlock:^id(id obj, NSUInteger _, BOOL *__) {
                                                               return [self treeNodeForCategory:obj withParent:node];
                                                           }];

                                                       dispatch_semaphore_signal(waitSemaphore);
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

@end
