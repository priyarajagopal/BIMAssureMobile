//
//  INVModelTreeNode.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeNode.h"

#import <AWPagedArray/AWPagedArray.h>

#define OBJECTS_PER_PAGE 20

@interface INVModelTreeNode () <AWPagedArrayDelegate>

@property (nonatomic) dispatch_queue_t loadingQueue;
@property (nonatomic, copy) INVModelTreeNodeFetchChildrenBlock fetchChildrenBlock;
@property (readwrite) AWPagedArray *pagedChildren;

@end

@implementation INVModelTreeNode

- (dispatch_queue_t)loadingQueue
{
    if (_parent) {
        return _parent.loadingQueue;
    }

    if (_loadingQueue == nil) {
        char nameBuffer[256];
        snprintf(nameBuffer, 256, "com.invicara.model-tree-queue.%s", [self.name UTF8String]);

        _loadingQueue = dispatch_queue_create(nameBuffer, DISPATCH_QUEUE_SERIAL);
    }

    return _loadingQueue;
}

+ (instancetype)treeNodeWithName:(NSString *)name
                              id:(NSNumber *)id
                 andLoadingBlock:(INVModelTreeNodeFetchChildrenBlock)fetchChildrenBlock
{
    return [[self alloc] initWithName:name id:id andLoadingBlock:fetchChildrenBlock];
}

- (id)initWithName:(NSString *)name id:(NSNumber *)id andLoadingBlock:(INVModelTreeNodeFetchChildrenBlock)fetchChildrenBlock
{
    if (self = [super init]) {
        _name = name;
        _id = id;

        _pagedChildren = [[AWPagedArray alloc] initWithCount:0 objectsPerPage:OBJECTS_PER_PAGE initialPageIndex:0];
        _pagedChildren.delegate = self;

        _fetchChildrenBlock = fetchChildrenBlock;
    }

    return self;
}

- (void)pagedArray:(AWPagedArray *)pagedArray willAccessIndex:(NSUInteger)index returnObject:(__autoreleasing id *)returnObject
{
    if ([*returnObject isKindOfClass:[NSNull class]]) {
        [self loadPageAtIndex:[pagedArray pageForIndex:index] force:NO];
    }
    else {
        NSUInteger page = [pagedArray pageForIndex:index] + 1;

        [self loadPageAtIndex:page force:NO];
    }
}

- (void)loadPageAtIndex:(NSUInteger)pageIndex force:(BOOL)force
{
    dispatch_async(self.loadingQueue, ^{
        if (self.pagedChildren.pages[@(pageIndex)] != nil && !force) {
            return;
        }

        dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);

        NSInteger expectedTotalCount = [self.children count];
        __strong NSError *error = nil;
        __block NSArray *objects = nil;

        void (^completionHandler)(NSArray *) = ^(NSArray *data) {
            if (objects) {
                return;
            }

            objects = data;
            dispatch_semaphore_signal(waitSemaphore);
        };

        BOOL hasData = self.fetchChildrenBlock(self,
            NSMakeRange(pageIndex * self.pagedChildren.objectsPerPage, self.pagedChildren.objectsPerPage), &expectedTotalCount,
            &error, completionHandler);

        if (hasData) {
            dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_FOREVER);

            if (error) {
                INVLogError(@"%@", error);

                objects = nil;
            }
        }

        if (objects == nil) {
            objects = @[];
        }

        [self willChangeValueForKey:@"children"];

        if (self.pagedChildren.totalCount > expectedTotalCount) {
            [self.pagedChildren invalidateContents];
        }

        self.pagedChildren.totalCount = expectedTotalCount;

        NSInteger currentPageIndex = pageIndex;
        do {
            NSArray *currentPageItems =
                [objects subarrayWithRange:NSMakeRange(0, MIN(self.pagedChildren.objectsPerPage, objects.count))];

            [self.pagedChildren setObjects:currentPageItems forPage:currentPageIndex];

            objects = [objects subarrayWithRange:NSMakeRange(currentPageItems.count, objects.count - currentPageItems.count)];
            currentPageIndex++;
        } while (objects.count);

        [self didChangeValueForKey:@"children"];
    });
}

#pragma mark - Accessors

- (NSArray *)children
{
    [self loadPageAtIndex:0 force:NO];

    return (NSArray *) _pagedChildren;
}

- (INVModelTreeNodeFetchChildrenBlock)fetchChildrenBlock
{
    // This way we only have to null check in one place.
    return _fetchChildrenBlock ?: ^BOOL(INVModelTreeNode *node, NSRange range, NSInteger *expectedCount,
                                      NSError *__strong *error, void (^complete)(NSArray *) ) {
        return NO;
    };
}

- (BOOL)isLeaf
{
    return _fetchChildrenBlock == nil;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    // Don't support copying
    return self;
}

- (NSUInteger)hash
{
    return [self.id hash];
}

@end
