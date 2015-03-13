//
//  INVMutableSectionedArray.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVMutableSectionedArray.h"

#define THROW_NOT_IMPLEMENTED()                                                                                                \
    [NSException raise:NSInvalidArgumentException                                                                              \
                format:@"Cannot call %@ on an instance of %@", NSStringFromSelector(_cmd), [self class]]

@implementation INVMutableSectionedArraySection

- (id)init
{
    if (self = [super init]) {
        _range = NSMakeRange(NSNotFound, 0);
    }

    return self;
}

@synthesize range = _range;

- (NSRange)range
{
    if (_range.location == NSNotFound) {
        return NSMakeRange(0, self.array.count);
    }

    return _range;
}

- (void)setRange:(NSRange)range
{
    _range = range;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@" {{%p} [%lu-%lu]}", self.array, (unsigned long) self.range.location,
                                (unsigned long) self.range.length];
}

- (id)copyWithZone:(NSZone *)zone
{
    INVMutableSectionedArraySection *results = [[INVMutableSectionedArraySection allocWithZone:zone] init];
    results.array = self.array;
    results.range = self.range;
    results.userInfo = self.userInfo;

    return results;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[INVMutableSectionedArraySection class]]) {
        INVMutableSectionedArraySection *other = object;

        if (self.userInfo || other.userInfo) {
            return [self.userInfo isEqual:other.userInfo];
        }

        return [[other array] isEqual:[self array]] && other.range.location == self.range.location &&
               other.range.length == self.range.length;
    }

    return NO;
}

@end

@interface INVMutableSectionedArray ()

@property (readwrite) NSUInteger userInfoCount;
@property (readwrite) NSMutableArray *sections;

@end

@implementation INVMutableSectionedArray

- (id)init
{
    if (self = [super init]) {
        _sections = [NSMutableArray new];
    }

    return self;
}

#pragma mark - Not Implemented

- (void)addObject:(id)anObject
{
    THROW_NOT_IMPLEMENTED();
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    THROW_NOT_IMPLEMENTED();
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    THROW_NOT_IMPLEMENTED();
}

- (void)removeLastObject
{
    THROW_NOT_IMPLEMENTED();
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    THROW_NOT_IMPLEMENTED();
}

#pragma mark - Overriden

- (INVMutableSectionedArraySection *)sectionForIndex:(NSUInteger)index withAdjustedIndex:(NSUInteger *)adjusted
{
    for (INVMutableSectionedArraySection *section in _sections) {
        if (index < section.range.length) {
            if (adjusted) {
                *adjusted = index;
            }

            return section;
        }

        index -= section.range.length;
    }

    return nil;
}

- (void)insertArray:(NSArray *)array atIndex:(NSUInteger)index
{
    NSUInteger adjustedIndex = 0;
    INVMutableSectionedArraySection *firstHalf = [self sectionForIndex:index withAdjustedIndex:&adjustedIndex];
    if (firstHalf == nil) {
        if (index > 0) {
            [NSException raise:NSInvalidArgumentException format:@"Index %i out of range!", index];
        }

        return [self addObjectsFromArray:array];
    }

    // Split into three sections
    NSUInteger sectionIndex = [_sections indexOfObjectIdenticalTo:firstHalf];

    INVMutableSectionedArraySection *toInsert = [INVMutableSectionedArraySection new];
    INVMutableSectionedArraySection *secondHalf = [firstHalf copy];

    toInsert.userInfo = @(_userInfoCount++);
    toInsert.array = array;

    NSUInteger firstRangeStart = firstHalf.range.location;
    NSUInteger firstRangeEnd = firstRangeStart + adjustedIndex + 1;

    NSUInteger secondRangeStart = firstRangeEnd;
    NSUInteger secondRangeEnd = firstRangeStart + firstHalf.range.length;

    firstHalf.range = NSMakeRange(firstRangeStart, (firstRangeEnd - firstRangeStart));
    secondHalf.range = NSMakeRange(secondRangeStart, (secondRangeEnd - secondRangeStart));

    [_sections insertObject:toInsert atIndex:sectionIndex + 1];
    [_sections insertObject:secondHalf atIndex:sectionIndex + 2];
}

- (void)addObjectsFromArray:(NSArray *)otherArray
{
    INVMutableSectionedArraySection *section = [INVMutableSectionedArraySection new];
    section.array = otherArray;
    section.userInfo = @(_userInfoCount++);

    [_sections addObject:section];
}

- (void)removeObjectsInArray:(NSArray *)otherArray
{
    [_sections removeObjectsAtIndexes:[_sections indexesOfObjectsPassingTest:^BOOL(INVMutableSectionedArraySection *section,
                                                                                 NSUInteger _, BOOL *__) {
        return [section.array isEqual:otherArray];
    }]];
}

- (NSUInteger)count
{
    NSUInteger count = 0;
    for (INVMutableSectionedArraySection *section in _sections) {
        count += [section range].length;
    }

    return count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    NSUInteger adjustedIndex = 0;
    INVMutableSectionedArraySection *section = [self sectionForIndex:index withAdjustedIndex:&adjustedIndex];

    if (section == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Index %lu out of bounds!", (long) index];
    }

    return section.array[section.range.location + adjustedIndex];
}

- (id)rawObjectAtIndex:(NSUInteger)index
{
    NSUInteger adjustedIndex = 0;
    INVMutableSectionedArraySection *section = [self sectionForIndex:index withAdjustedIndex:&adjustedIndex];

    if (section == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Index %lu out of bounds!", (long) index];
    }

    if ([section.array respondsToSelector:@selector(rawObjectAtIndex:)]) {
        return [(id) section.array rawObjectAtIndex:section.range.location + adjustedIndex];
    }

    return [section.array objectAtIndex:section.range.location + adjustedIndex];
}

- (NSUInteger)rawIndexOfObject:(id)object
{
    for (NSUInteger index = 0; index < [self count]; index++) {
        if ([[self rawObjectAtIndex:index] isEqual:object]) {
            return index;
        }
    }

    return NSNotFound;
}

- (id)copy
{
    NSMutableArray *sections = [[NSMutableArray alloc] initWithArray:_sections copyItems:YES];
    for (INVMutableSectionedArraySection *section in sections) {
        section.array = [section.array subarrayWithRange:section.range];
        section.range = NSMakeRange(0, section.array.count);
    }

    INVMutableSectionedArray *copy = [INVMutableSectionedArray new];
    copy.sections = sections;

    return copy;
}

@end
