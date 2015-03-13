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

@property (nonatomic) NSMutableDictionary *nodeHeights;
@property BOOL shouldAnimatedPostUpdate;
@property (nonatomic, readwrite) INVModelTreeNodeTableViewCell *sizingCell;
@property (nonatomic, readwrite) INVModelTreeNode *rootNode;

@property (nonatomic, readonly) INVMutableSectionedArray *oldNodes;
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

    self.nodeHeights = [NSMutableDictionary new];

    UINib *modelTreeCellNib = [UINib nibWithNibName:@"INVModelTreeNodeTableViewCell" bundle:nil];
    self.sizingCell = [[modelTreeCellNib instantiateWithOwner:nil options:nil] firstObject];

    [self.tableView addSubview:self.sizingCell];
    [self.sizingCell setHidden:YES];

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
        BOOL animated = NO;

        if (context == NODE_LEVEL_CATEGORY) {
            if (change[NSKeyValueChangeNotificationIsPriorKey]) {
                _shouldAnimatedPostUpdate = [[object children] count] == 0;
                return;
            }
            else {
                animated = _shouldAnimatedPostUpdate;
                _shouldAnimatedPostUpdate = NO;
            }
        }

        [self performSelectorOnMainThread:@selector(reloadData:) withObject:@(animated) waitUntilDone:YES];
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

    if (_nodeHeights[node]) {
        return [_nodeHeights[node] floatValue];
    }

    self.sizingCell.indentationLevel = [self tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    self.sizingCell.node = node;

    [self.sizingCell setNeedsUpdateConstraints];
    [self.sizingCell layoutIfNeeded];

    CGFloat height = [self.sizingCell systemLayoutSizeFittingSize:CGSizeMake(self.tableView.bounds.size.width, 0)
                                    withHorizontalFittingPriority:UILayoutPriorityRequired
                                          verticalFittingPriority:UILayoutPriorityDefaultLow].height;
    _nodeHeights[node] = @(height);

    return height;
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

- (IBAction)onModelTreeNodeDetailsSelected:(id)sender
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

    viewController.popoverPresentationController.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];

    // This should be the accessory button.
    UIView *anchor = sender;

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

            [results insertArray:object.children atIndex:[results rawIndexOfObject:object]];
        }
    };

    weakBlock = iterateBlock;

    [results addObjectsFromArray:self.rootNode.children];
    [(AWPagedArray *) self.rootNode.children enumerateExistingObjectsUsingBlock:weakBlock];

    _flattenedNodes = results;

    return _flattenedNodes;
}

- (NSArray *)arrayWithIndexPathsInRange:(NSRange)range forSection:(NSUInteger)section
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSUInteger row = range.location; row < range.location + range.length; row++) {
        [results addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }

    return [results copy];
}

- (void)reloadData:(NSNumber *)animated
{
    animated = @NO;

    // This flushes the cache
    _flattenedNodes = nil;

    INVMutableSectionedArray *newNodes = self.flattenedNodes;

    if ([animated boolValue]) {
        [self.tableView beginUpdates];

        // First step, remove all old sections
        NSUInteger currentIndex = 0;
        for (INVMutableSectionedArraySection *section in _oldNodes.sections) {
            NSRange sectionRange = NSMakeRange(currentIndex, section.range.length);
            NSArray *sectionRows = [self arrayWithIndexPathsInRange:sectionRange forSection:0];

            if (![[newNodes sections] containsObject:section]) {
                [self.tableView deleteRowsAtIndexPaths:sectionRows withRowAnimation:UITableViewRowAnimationLeft];
                continue;
            }

            currentIndex += section.range.length;
        }

        currentIndex = 0;
        for (INVMutableSectionedArraySection *section in newNodes.sections) {
            NSRange sectionRange = NSMakeRange(currentIndex, section.range.length);
            NSArray *sectionRows = [self arrayWithIndexPathsInRange:sectionRange forSection:0];

            if ([_oldNodes.sections containsObject:section]) {
                INVMutableSectionedArraySection *oldSection =
                    [_oldNodes.sections objectAtIndex:[_oldNodes.sections indexOfObject:section]];

                // Initial content load
                if (oldSection.range.length == 0) {
                    [self.tableView insertRowsAtIndexPaths:sectionRows withRowAnimation:UITableViewRowAnimationLeft];
                }
                else {
                    // [self.tableView reloadRowsAtIndexPaths:sectionRows withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            else {
                [self.tableView insertRowsAtIndexPaths:sectionRows withRowAnimation:UITableViewRowAnimationLeft];
            }

            currentIndex += section.range.length;
        }

        [self.tableView endUpdates];
    }
    else {
        [self.tableView reloadData];
    }

    _oldNodes = [newNodes copy];
}

@end
