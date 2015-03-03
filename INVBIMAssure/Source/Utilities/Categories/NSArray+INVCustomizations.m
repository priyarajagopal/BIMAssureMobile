//
//  NSArray+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/3/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "NSArray+INVCustomizations.h"

@implementation NSArray (INVCustomizations)

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
