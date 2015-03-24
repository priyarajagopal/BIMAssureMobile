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

@interface NSObject_KVOBinding : NSObject

@property (strong) id selfObject;

@property (copy) NSString *sourceKeyPath;
@property (weak) id sourceObject;

@property (copy) NSString *targetKeyPath;
@property (weak) id targetObject;

@property (assign) BOOL bothWays;

- (id)initWithSource:(id)source
             keyPath:(NSString *)sourceKeyPath
              target:(id)target
             keyPath:(NSString *)targetKeyPath
            bothWays:(BOOL)bothWays;

+ (id)kvoBindingWithSource:(id)source
                   keyPath:(NSString *)sourceKeyPath
                    target:(id)target
                   keyPath:(NSString *)targetKeyPath
                  bothWays:(BOOL)bothWays;

@end

@implementation NSObject_KVOBinding

- (id)initWithSource:(id)source
             keyPath:(NSString *)sourceKeyPath
              target:(id)target
             keyPath:(NSString *)targetKeyPath
            bothWays:(BOOL)bothWays
{
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;

        self.selfObject = self;
        self.sourceObject = source;
        self.sourceKeyPath = sourceKeyPath;
        self.targetObject = target;
        self.targetKeyPath = targetKeyPath;
        self.bothWays = bothWays;

        [self.sourceObject addObserver:self
                            forKeyPath:self.sourceKeyPath
                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                               context:NULL];

        [self.sourceObject addDeallocHandler:^(id source) {
            [source removeObserver:weakSelf forKeyPath:weakSelf.sourceKeyPath];
            if (weakSelf.targetObject == nil) {
                weakSelf.selfObject = nil;
            }
        }];

        if (bothWays) {
            [self.targetObject addObserver:self
                                forKeyPath:self.targetKeyPath
                                   options:NSKeyValueObservingOptionNew
                                   context:NULL];

            [self.targetObject addDeallocHandler:^(id target) {
                [target removeObserver:weakSelf forKeyPath:weakSelf.targetKeyPath];

                if (weakSelf.sourceObject == nil) {
                    weakSelf.selfObject = nil;
                }
            }];
        }
    }

    return self;
}

+ (id)kvoBindingWithSource:(id)source
                   keyPath:(NSString *)sourceKeyPath
                    target:(id)target
                   keyPath:(NSString *)targetKeyPath
                  bothWays:(BOOL)bothWays
{
    return [[self alloc] initWithSource:source keyPath:sourceKeyPath target:target keyPath:targetKeyPath bothWays:bothWays];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id source = self.sourceObject;
    id target = self.targetObject;

    if (source == nil || target == nil) {
        return;
    }

    id newValue = change[NSKeyValueChangeNewKey];
    if ([newValue isKindOfClass:[NSNull class]]) {
        newValue = [object valueForKeyPath:keyPath];
    }

    if (object == source && [keyPath isEqual:self.sourceKeyPath]) {
        id oldValue = [target valueForKeyPath:self.targetKeyPath];

        if (![oldValue isEqual:newValue]) {
            [target setValue:newValue forKeyPath:self.targetKeyPath];
        }
    }
    else if (self.bothWays && object == target && [keyPath isEqual:self.targetKeyPath]) {
        id oldValue = [source valueForKey:self.sourceKeyPath];

        if (![oldValue isEqual:newValue]) {
            [source setValue:newValue forKeyPath:self.sourceKeyPath];
        }
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

- (NSMutableArray *)_bindingsForKeyPath:(NSString *)keyPath
{
    // objc's associated objects NEVER dereference the pointer you use for the key. this allows us to 'intern' the string by
    // simply taking a pointer with the contents of their hash.
    void *key = (void *) [keyPath hash];
    id results = nil;

    if ((results = objc_getAssociatedObject(self, key))) {
        return results;
    }

    results = [NSMutableArray new];
    objc_setAssociatedObject(self, key, results, OBJC_ASSOCIATION_RETAIN);

    return results;
}

- (void)bindKeyPath:(NSString *)keyPath toObject:(id)object
{
    [self bindKeyPath:keyPath toObject:object keyPath:keyPath];
}

- (void)bindKeyPath:(NSString *)ourKeyPath toObject:(id)object keyPath:(NSString *)theirKeyPath
{
    [self bindKeyPath:ourKeyPath toObject:object keyPath:theirKeyPath bothWays:NO];
}

- (void)bindKeyPath:(NSString *)ourKeyPath toObject:(id)object keyPath:(NSString *)theirKeyPath bothWays:(BOOL)bothWays
{
    NSObject_KVOBinding *binding = [[NSObject_KVOBinding alloc] initWithSource:self
                                                                       keyPath:ourKeyPath
                                                                        target:object
                                                                       keyPath:theirKeyPath
                                                                      bothWays:bothWays];

    [[self _bindingsForKeyPath:ourKeyPath] addObject:binding];
    [[object _bindingsForKeyPath:theirKeyPath] addObject:binding];
}

- (void)unbindKeyPath:(NSString *)keypath
{
    [self unbindKeyPath:keypath fromObject:nil];
}

- (void)unbindKeyPath:(NSString *)keypath fromObject:(id)object
{
    [self unbindKeyPath:keypath fromObject:object keyPath:nil];
}

- (void)unbindKeyPath:(NSString *)keypath fromObject:(id)object keyPath:(NSString *)keyPath
{
    [self unbindKeyPath:keypath fromObject:object keyPath:keypath bothWays:NO];
}

- (void)unbindKeyPath:(NSString *)ourKeyPath fromObject:(id)object keyPath:(NSString *)theirKeyPath bothWays:(BOOL)bothWays
{
    NSMutableArray *ourBindings = [self _bindingsForKeyPath:ourKeyPath];

    [ourBindings removeObjectsAtIndexes:[ourBindings indexesOfObjectsPassingTest:^BOOL(NSObject_KVOBinding *binding,
                                                                                     NSUInteger idx, BOOL *stop) {
        if (object != nil && object != binding.targetObject)
            return NO;

        if (theirKeyPath != nil && theirKeyPath != binding.targetKeyPath)
            return NO;

        if (bothWays != binding.bothWays)
            return NO;

        return YES;
    }]];
}

@end
