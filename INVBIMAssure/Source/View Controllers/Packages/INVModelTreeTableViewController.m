//
//  INVModelTreeTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeTableViewController.h"

@interface INVModelTreeNode : NSObject

@property (nonatomic, strong) INVModelTreeNode *parent;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *children;
@property (nonatomic, getter=isExpanded) BOOL expanded;

+(instancetype) treeNodeWithName:(NSString *) name children:(NSArray *) children;
-(id) initWithName:(NSString *) name children:(NSArray *) children;

@end

@implementation INVModelTreeNode

+(instancetype) treeNodeWithName:(NSString *)name children:(NSArray *)children {
    return [[self alloc] initWithName:name children:children];
}

-(id) initWithName:(NSString *)name children:(NSArray *)children {
    if (self = [super init]) {
        self.name = name;
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

-(void) awakeFromNib {
    [self updateUI];
}

-(void) setNode:(INVModelTreeNode *)node {
    _node = node;
    
    [self updateUI];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets margins = self.contentView.layoutMargins;
    margins.left = 8 + (self.indentationLevel * self.indentationWidth);
    
    self.contentView.layoutMargins = margins;
}

-(void) updateUI {
    self.nameLabel.text = self.node.name;
    
    self.expandedIndicator.text = self.node.expanded ? @"\uf0d7" : @"\uf0da";
    self.expandedIndicator.hidden = (self.node.children.count == 0);
}

@end

@interface INVModelTreeTableViewController ()

@property (nonatomic, copy) NSArray *rootNodes;
@property (nonatomic, readonly) NSArray *flattenedNodes;

@end

@implementation INVModelTreeTableViewController

// Force iVar generation for readonly property
@synthesize flattenedNodes=_flattenedNodes;

-(NSArray *) flattenedNodes {
    if (_flattenedNodes) return _flattenedNodes;
    
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

-(void) reloadData {
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
            [self.tableView deleteRowsAtIndexPaths:@[
                [NSIndexPath indexPathForRow:index inSection:0]
            ] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            if (lastStableIndex) {
                [self.tableView reloadRowsAtIndexPaths:@[
                    [NSIndexPath indexPathForRow:lastStableIndex inSection:0]
                ] withRowAnimation:UITableViewRowAnimationNone];
                
                lastStableIndex = -1;
            }
        } else if (index != newIndex) {
            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                   toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
        } else {
            lastStableIndex = index;
        }
    }
    
    lastStableIndex = -1;
    for (NSUInteger index = 0; index < newNodes.count; index++) {
        INVModelTreeNode *node = newNodes[index];
        NSUInteger oldIndex = [oldNodes indexOfObject:node];
        
        if (oldIndex == NSNotFound) {
            [self.tableView insertRowsAtIndexPaths:@[
                [NSIndexPath indexPathForRow:index inSection:0]
            ] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            if (lastStableIndex) {
                [self.tableView reloadRowsAtIndexPaths:@[
                    [NSIndexPath indexPathForRow:lastStableIndex inSection:0]
                ] withRowAnimation:UITableViewRowAnimationNone];
                
                lastStableIndex = -1;
            }
        } else {
            lastStableIndex = index;
        }
    }
    
    [self.tableView endUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
    self.rootNodes = @[
        [INVModelTreeNode treeNodeWithName:@"All data is currently FAKE!" children:nil],
        [INVModelTreeNode treeNodeWithName:@"Section A" children:@[
            [INVModelTreeNode treeNodeWithName:@"Child A" children:nil],
            [INVModelTreeNode treeNodeWithName:@"Child B" children:nil],
            [INVModelTreeNode treeNodeWithName:@"Child C" children:@[
               [INVModelTreeNode treeNodeWithName:@"Subchild A" children:nil],
               [INVModelTreeNode treeNodeWithName:@"Subchild B" children:nil],
               [INVModelTreeNode treeNodeWithName:@"Subchild C" children:nil],
            ]]
        ]],
        [INVModelTreeNode treeNodeWithName:@"Section B" children:nil]
    ];
 
    [self _generateParents:self.rootNodes parent:nil];
    [self reloadData];
}

-(void) _generateParents:(NSArray *) nodes parent:(INVModelTreeNode *) parent {
    for (INVModelTreeNode *node in nodes) {
        node.parent = parent;
        
        [self _generateParents:node.children parent:node];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.flattenedNodes count];
}

-(NSInteger) tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    INVModelTreeNode *node = self.flattenedNodes[indexPath.row];
    NSInteger depth = -1;
    
    do {
        node = node.parent;
        depth++;
    } while (node != nil);
    
    return depth;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    INVModelTreeNodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"treeCell"];
    INVModelTreeNode *node = self.flattenedNodes[indexPath.row];
    
    cell.node = node;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    INVModelTreeNode *node = self.flattenedNodes[indexPath.row];
    
    if (node.children.count) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        node.expanded = !node.expanded;
    
        [self reloadData];
    }
}

@end
