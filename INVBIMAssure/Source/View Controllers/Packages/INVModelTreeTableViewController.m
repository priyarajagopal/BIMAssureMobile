//
//  INVModelTreeTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeTableViewController.h"
#import "NSArray+INVCustomizations.h"
#import "UIView+INVCustomizations.h"
#import "INVBuildingElementPropertiesTableViewController.h"

@interface INVModelTreeNode : NSObject

@property (nonatomic, strong) INVModelTreeNode *parent;

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *children;

@property (nonatomic, getter=isExpanded) BOOL expanded;

+ (instancetype)treeNodeWithName:(NSString *)name id:(NSNumber *)id children:(NSArray *)children;
- (id)initWithName:(NSString *)name id:(NSNumber *)id children:(NSArray *)children;

@end

@implementation INVModelTreeNode

+ (instancetype)treeNodeWithName:(NSString *)name id:(NSNumber *)id children:(NSArray *)children
{
    return [[self alloc] initWithName:name id:id children:children];
}

- (id)initWithName:(NSString *)name id:(NSNumber *)id children:(NSArray *)children
{
    if (self = [super init]) {
        self.name = name;
        self.id = id;
        self.children = children;
    }

    return self;
}

@end

@interface INVModelTreeNodeTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic) IBOutlet UILabel *expandedIndicator;

@property (nonatomic) INVModelTreeNode *node;

@end

@implementation INVModelTreeNodeTableViewCell

- (void)awakeFromNib
{
    [self updateUI];
}

- (void)setNode:(INVModelTreeNode *)node
{
    _node = node;

    [self updateUI];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateUI];

    UIEdgeInsets margins = self.contentView.layoutMargins;
    margins.left = 8 + (self.indentationLevel * self.indentationWidth);

    self.contentView.layoutMargins = margins;
}

- (void)updateUI
{
    self.nameLabel.text = self.node.name;

    self.expandedIndicator.text = self.node.expanded ? @"\uf0d7" : @"\uf0da";
    self.expandedIndicator.hidden = (self.indentationLevel > 0);

    self.accessoryType = (self.indentationLevel > 0) ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
}

@end

@interface INVModelTreeTableViewController ()

@property (nonatomic, copy) NSArray *rootNodes;
@property (nonatomic, readonly) NSArray *flattenedNodes;

@end

@implementation INVModelTreeTableViewController

#pragma mark - View Lifecyle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;

    self.packageVersionId = @(0);

    [self.globalDataManager.invServerClient
        fetchBuildingElementCategoriesForPackageVersionId:self.packageVersionId
                                      withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                          NSArray *categories = [result valueForKeyPath:@"aggregations.category.buckets.key"];

                                          self.rootNodes =
                                              [categories arrayByApplyingBlock:^id(id obj, NSUInteger _, BOOL *__) {
                                                  return [INVModelTreeNode treeNodeWithName:obj id:@([obj hash]) children:nil];
                                              }];

                                          [self _generateParents:self.rootNodes parent:nil];
                                          [self reloadData];
                                      }];

    self.rootNodes = @[];

    [self _generateParents:self.rootNodes parent:nil];
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    INVModelTreeNode *node = self.flattenedNodes[indexPath.row];
    NSInteger depth = -1;

    do {
        node = node.parent;
        depth++;
    } while (node != nil);

    return depth;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVModelTreeNodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"treeCell"];
    INVModelTreeNode *node = self.flattenedNodes[indexPath.row];

    cell.node = node;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    [cell prepareForReuse];
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVModelTreeNode *node = self.flattenedNodes[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (node.parent == nil) {
        // Load the category contents
        node.expanded = !node.expanded;

        [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];

        [self.globalDataManager.invServerClient
            fetchBuildingElementOfSpecifiedCategoryWithDisplayname:node.name
                                               ForPackageVersionId:self.packageVersionId
                                               withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                                   NSArray *hits = [result valueForKeyPath:@"hits.hits"];
                                                   NSArray *ids = [hits valueForKeyPath:@"_id"];
                                                   NSArray *names =
                                                       [[[hits valueForKey:@"fields"] valueForKey:@"intrinsics.name.display"]
                                                           valueForKeyPath:@"@unionOfArrays.self"];

                                                   NSDictionary *elements =
                                                       [[NSDictionary alloc] initWithObjects:names forKeys:ids];

                                                   NSMutableArray *children = [NSMutableArray new];

                                                   [elements enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                                       [children addObject:[INVModelTreeNode treeNodeWithName:obj
                                                                                                           id:key
                                                                                                     children:nil]];
                                                   }];

                                                   node.children = [children copy];

                                                   [self _generateParents:node.children parent:node];
                                                   [self reloadData];
                                               }];
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

// Force iVar generation for readonly property
@synthesize flattenedNodes = _flattenedNodes;

- (NSArray *)flattenedNodes
{
    if (_flattenedNodes)
        return _flattenedNodes;

    NSMutableArray *results = [NSMutableArray new];

    __weak __block id weakBlock;
    void (^iterateBlock)(id, NSUInteger, BOOL *) = ^(INVModelTreeNode *object, NSUInteger index, BOOL *stop) {
        [results addObject:object];

        if (object.isExpanded) {
            [object.children enumerateObjectsUsingBlock:weakBlock];
        }
    };

    weakBlock = iterateBlock;
    [self.rootNodes enumerateObjectsUsingBlock:weakBlock];

    _flattenedNodes = [results copy];

    return _flattenedNodes;
}

- (void)reloadData
{
    NSArray *oldNodes = self.flattenedNodes;

    // This flushes the cache
    _flattenedNodes = nil;

    NSArray *newNodes = self.flattenedNodes;

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

- (void)_generateParents:(NSArray *)nodes parent:(INVModelTreeNode *)parent
{
    for (INVModelTreeNode *node in nodes) {
        node.parent = parent;

        [self _generateParents:node.children parent:node];
    }
}

@end
