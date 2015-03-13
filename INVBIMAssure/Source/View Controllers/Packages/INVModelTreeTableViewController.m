//
//  INVModelTreeTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeTableViewController.h"
#import "INVBuildingElementPropertiesTableViewController.h"

#import "NSArray+INVCustomizations.h"
#import "UIView+INVCustomizations.h"
#import "NSObject+INVCustomizations.h"

#import "INVModelTreeNode.h"
#import "INVModelTreeNodeTableViewCell.h"

#import "INVMutableSectionedArray.h"
#import <AWPagedArray/AWPagedArray.h>

#define CONTEXT_NODE_LEVEL(n) ((void *) (n))

#define NODE_LEVEL_ROOT CONTEXT_NODE_LEVEL(0)
#define NODE_LEVEL_CATEGORY CONTEXT_NODE_LEVEL(1)
#define NODE_LEVEL_ELEMENT CONTEXT_NODE_LEVEL(2)

@interface INVModelTreeTableViewController ()

@property (nonatomic, readwrite) INVModelTreeNodeTableViewCell *sizingCell;
@property (nonatomic, readwrite) INVModelTreeNode *rootNode;
@property (nonatomic, readonly) INVMutableSectionedArray *flattenedNodes;

@end

@implementation INVModelTreeTableViewController

#pragma mark - View Lifecyle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;

    UINib *modelTreeCellNib = [UINib nibWithNibName:@"INVModelTreeNodeTableViewCell" bundle:nil];
    self.sizingCell = [[modelTreeCellNib instantiateWithOwner:nil options:nil] firstObject];

    [self.tableView registerNib:modelTreeCellNib forCellReuseIdentifier:@"treeCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadData:@NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"children"]) {
        [self performSelectorOnMainThread:@selector(reloadData:) withObject:@YES waitUntilDone:NO];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flattenedNodes count];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVModelTreeNode *node = [self.flattenedNodes rawObjectAtIndex:indexPath.row];
    if ([node isKindOfClass:[NSNull class]]) {
        return 0;
    }

    NSInteger depth = 0;

    while (![node isKindOfClass:[NSNull class]] && node.parent != self.rootNode) {
        depth++;
        node = node.parent;
    }

    return depth;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVModelTreeNodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"treeCell"];
    INVModelTreeNode *node = self.flattenedNodes[indexPath.row];

    cell.node = node;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVModelTreeNode *node = [self.flattenedNodes rawObjectAtIndex:indexPath.row];
    if ([node isKindOfClass:[NSNull class]]) {
        return tableView.rowHeight;
    }

    self.sizingCell.node = node;
    self.sizingCell.indentationLevel = [self tableView:tableView indentationLevelForRowAtIndexPath:indexPath];

    [self.sizingCell setNeedsUpdateConstraints];
    [self.sizingCell layoutIfNeeded];

    return [self.sizingCell systemLayoutSizeFittingSize:CGSizeMake(self.tableView.bounds.size.width, 0)
                          withHorizontalFittingPriority:UILayoutPriorityRequired
                                verticalFittingPriority:UILayoutPriorityDefaultLow].height;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVModelTreeNode *node = self.flattenedNodes[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (node.parent.parent == nil) {
        // Load the category contents
        node.expanded = !node.expanded;

        [self reloadData:@YES];
    }
    else {
        // TODO: Highlight in viewer.
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    INVModelTreeNode *node = self.flattenedNodes[indexPath.row];

    INVModelTreeNodeTableViewCell *cell = (INVModelTreeNodeTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    UINavigationController *viewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"ViewPropertiesNC"];

    INVBuildingElementPropertiesTableViewController *propertiesViewController =
        (INVBuildingElementPropertiesTableViewController *) [viewController topViewController];
    propertiesViewController.packageVersionId = self.packageVersionId;
    propertiesViewController.buildingElementCategory = node.parent.name;
    propertiesViewController.buildingElementName = node.name;
    propertiesViewController.buildingElementId = node.id;

    viewController.modalPresentationStyle = UIModalPresentationPopover;

    [self presentViewController:viewController animated:YES completion:nil];

    viewController.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];

    // This should be the accessory button.
    UIView *anchor = [cell findSubviewOfClass:[UIImageView class] predicate:[NSPredicate predicateWithFormat:@"image != null"]];

    viewController.popoverPresentationController.sourceView = anchor;
    viewController.popoverPresentationController.sourceRect = [anchor bounds];
    viewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionLeft;
}

#pragma mark - Content Management

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

    [node addObserver:self forKeyPath:@"children" options:0 context:NODE_LEVEL_CATEGORY];
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

        [_rootNode addObserver:self forKeyPath:@"children" options:0 context:NODE_LEVEL_ROOT];

        __weak typeof(self) weakSelf = self;
        [_rootNode addDeallocHandler:^(id rootNode) {
            [rootNode removeObserver:weakSelf forKeyPath:@"children"];
        }];
    }

    return _rootNode;
}

// Force iVar generation for readonly property
@synthesize flattenedNodes = _flattenedNodes;

- (INVMutableSectionedArray *)flattenedNodes
{
    if (_flattenedNodes)
        return _flattenedNodes;

    INVMutableSectionedArray *results = [INVMutableSectionedArray new];

    __weak __block id weakBlock;
    void (^iterateBlock)(id, NSUInteger, BOOL *) = ^(INVModelTreeNode *object, NSUInteger index, BOOL *stop) {
        if (object.isExpanded) {
            [(AWPagedArray *) object.children enumerateExistingObjectsUsingBlock:weakBlock];

            [results insertArray:object.children atIndex:index];
        }
    };

    weakBlock = iterateBlock;

    [results addObjectsFromArray:self.rootNode.children];
    [(AWPagedArray *) self.rootNode.children enumerateExistingObjectsUsingBlock:weakBlock];

    _flattenedNodes = results;

    return _flattenedNodes;
}

- (void)reloadData:(NSNumber *)animated
{
    animated = @NO;

    NSArray *oldNodes = self.flattenedNodes;

    // This flushes the cache
    _flattenedNodes = nil;

    NSArray *newNodes = self.flattenedNodes;

    if ([animated boolValue]) {
        [self.tableView beginUpdates];

        NSUInteger lastStableIndex = -1;
        for (NSUInteger index = 0; index < oldNodes.count; index++) {
            INVModelTreeNode *node = oldNodes[index];
            NSUInteger newIndex = [newNodes indexOfObject:node];

            if (newIndex == NSNotFound) {
                [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];

                if (lastStableIndex) {
                    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:lastStableIndex inSection:0] ]
                                          withRowAnimation:UITableViewRowAnimationNone];

                    lastStableIndex = -1;
                }
            }
            else if (index != newIndex) {
                [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                       toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
            }
            else {
                lastStableIndex = index;
            }
        }

        lastStableIndex = -1;
        for (NSUInteger index = 0; index < newNodes.count; index++) {
            INVModelTreeNode *node = newNodes[index];
            NSUInteger oldIndex = [oldNodes indexOfObject:node];

            if (oldIndex == NSNotFound) {
                [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];

                if (lastStableIndex) {
                    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:lastStableIndex inSection:0] ]
                                          withRowAnimation:UITableViewRowAnimationNone];

                    lastStableIndex = -1;
                }
            }
            else {
                lastStableIndex = index;
            }
        }

        [self.tableView endUpdates];
    }
    else {
        [self.tableView reloadData];
    }
}

@end
