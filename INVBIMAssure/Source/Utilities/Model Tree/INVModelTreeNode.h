//
//  INVModelTreeNode.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class INVModelTreeNode;

typedef NSArray * (^INVModelTreeNodeFetchChildrenBlock)(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount);

@interface INVModelTreeNode : NSObject

@property (nonatomic, strong) INVModelTreeNode *parent;

@property (nonatomic, readonly, copy) id id;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray *children;

@property (nonatomic, getter=isExpanded) BOOL expanded;

+ (instancetype)treeNodeWithName:(NSString *)name
                              id:(id)id
                 andLoadingBlock:(INVModelTreeNodeFetchChildrenBlock)fetchChildrenBlock;
- (id)initWithName:(NSString *)name id:(id)id andLoadingBlock:(INVModelTreeNodeFetchChildrenBlock)fetchChildrenBlock;

@end
