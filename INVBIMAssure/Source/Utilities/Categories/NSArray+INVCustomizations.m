//
//  NSArray+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/3/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "NSArray+INVCustomizations.h"

@interface SingleObjectArray : NSArray

- (id)initWithObject:(id)object count:(NSUInteger)count;

@property id object;

@end

@implementation SingleObjectArray

@synthesize count = _count;

- (id)initWithObject:(id)object count:(NSUInteger)count
{
    if (self = [super init]) {
        _object = object;
        _count = count;
    }

    return self;
}

- (id)objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        [NSException raise:NSRangeException format:@"Index %lu out of range!", (unsigned long) index];
    }

    return _object;
}

@end

@implementation NSArray (INVCustomizations)

+ (NSArray *)arrayWithObject:(id)object repeated:(NSUInteger)times
{
    return [[SingleObjectArray alloc] initWithObject:object count:times];
}

- (NSArray *)arrayByApplyingExpression:(NSExpression *)expression
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[self count]];

    for (id obj in self) {
        [results addObject:[expression expressionValueWithObject:obj context:nil]];
    }

    return [results copy];
}

- (NSArray *)arrayByApplyingBlock:(id (^)(id, NSUInteger, BOOL *))block
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[self count]];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [results addObject:block(obj, idx, stop)];
    }];

    return [results copy];
}

@end
