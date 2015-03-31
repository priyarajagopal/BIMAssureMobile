//
//  INVModelTreeBaseViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeBaseViewController.h"

#import "NSArray+INVCustomizations.h"
#import "UIView+INVCustomizations.h"
#import "NSObject+INVCustomizations.h"

#import "INVModelTreeNode.h"
#import "INVModelTreeNodeTableViewCell.h"

#import "INVMutableSectionedArray.h"
#import <AWPagedArray/AWPagedArray.h>

@interface INVModelTreeBaseViewController ()

@property (nonatomic) NSMutableDictionary *nodeHeights;
@property BOOL shouldAnimatedPostUpdate;
@property (nonatomic, readwrite) INVModelTreeNodeTableViewCell *sizingCell;

@property (nonatomic, readonly) INVMutableSectionedArray *oldNodes;
@property (nonatomic, readonly) INVMutableSectionedArray *flattenedNodes;

@end

@implementation INVModelTreeBaseViewController

#pragma mark - View Lifecyle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;
    //  self.tableView.backgroundColor = [UIColor clearColor];
    //  self.tableView.backgroundView = nil;

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

        if (context) {
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

    if (!node.isLeaf) {
        // Load the category contents
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        node.expanded = !node.expanded;

        [self reloadData:@YES];
    }
}

- (IBAction)onModelTreeNodeDetailsSelected:(id)sender
{
    [NSException raise:NSInvalidArgumentException
                format:@"%@ did not implement -onModelTreeNodeDetailsSelected:!", [self class]];
}

#pragma mark - Content Management

- (INVModelTreeNode *)rootNode
{
    [NSException raise:NSInvalidArgumentException format:@"%@ did not implement -rootNode!", [self class]];

    return nil;
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
            [results insertArray:object.children atIndex:[results rawIndexOfObject:object]];

            [(AWPagedArray *) object.children enumerateExistingObjectsUsingBlock:weakBlock];
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

- (void)registerNode:(INVModelTreeNode *)node animateChanges:(BOOL)animated
{
    static void *contextPtr = &contextPtr;
    __weak typeof(self) weakSelf = self;

    [node addObserver:self forKeyPath:@"children" options:NSKeyValueObservingOptionPrior context:animated ? contextPtr : NULL];
    [node addDeallocHandler:^(id node) {
        [node removeObserver:weakSelf forKeyPath:@"children"];
    }];
}

@end
