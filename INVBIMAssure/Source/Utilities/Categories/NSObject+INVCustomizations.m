//
//  NSObject+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/26/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "NSObject+INVCustomizations.h"

@import ObjectiveC.runtime;

@interface NSObject_DeallocHandler : NSObject

@property (copy) void (^blockToRun)(id);
@property (assign) id theObject;

- (id)initWithBlock:(void (^)(id))block onObject:(id)object;
+ (id)deallocHandlerWithBlock:(void (^)(id))block onObject:(id)object;

@end

@implementation NSObject_DeallocHandler

- (id)initWithBlock:(void (^)(id))block onObject:(id)object
{
    if (self = [super init]) {
        self.blockToRun = block;
        self.theObject = object;
    }

    return self;
}

+ (id)deallocHandlerWithBlock:(void (^)(id))block onObject:(id)object
{
    return [[self alloc] initWithBlock:block onObject:object];
}

- (void)dealloc
{
    if (self.blockToRun) {
        self.blockToRun(self.theObject);
    }
}

@end

@implementation NSObject (INVCustomizations)

- (id)addDeallocHandler:(void (^)(id))block
{
    NSObject_DeallocHandler *deallocHandler = [NSObject_DeallocHandler deallocHandlerWithBlock:block onObject:self];
    objc_setAssociatedObject(self, (__bridge void *) block, deallocHandler, OBJC_ASSOCIATION_RETAIN);

    return self;
}

- (void)removeDeallocHandler:(void (^)(id))block
{
    objc_setAssociatedObject(self, (__bridge void *) block, nil, OBJC_ASSOCIATION_RETAIN);
}

@end
