//
//  INVModelTreeNode.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class INVModelTreeNode;

extern NSString *const INVModelTreeNodeNibNameKey;
extern NSString *const INVModelTreeNodeShowsDetailsKey;
extern NSString *const INVModelTreeNodeShowsExpandIndicatorKey;

typedef BOOL (^INVModelTreeNodeFetchChildrenBlock)(INVModelTreeNode *node, NSRange range, NSInteger *expectedTotalCount,
    NSError *__strong *error, void (^completed)(NSArray *));

@interface INVModelTreeNode : NSObject<NSCopying>

@property (nonatomic, strong) INVModelTreeNode *parent;

@property (nonatomic, copy) NSDictionary *userInfo;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, readonly, copy) NSArray *children;

@property (nonatomic, getter=isExpanded) BOOL expanded;
@property (nonatomic, readonly, getter=isLeaf) BOOL leaf;

+ (instancetype)treeNodeWithName:(NSString *)name
                        userInfo:(NSDictionary *)userInfo
                 andLoadingBlock:(INVModelTreeNodeFetchChildrenBlock)fetchChildrenBlock;

- (id)initWithName:(NSString *)name
           userInfo:(NSDictionary *)userInfo
    andLoadingBlock:(INVModelTreeNodeFetchChildrenBlock)fetchChildrenBlock;

@end
