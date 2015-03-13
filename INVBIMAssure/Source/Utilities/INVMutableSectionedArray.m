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

@interface INVMutableSectionedArraySection : NSObject

@property NSArray *array;
@property NSRange range;

@end

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

@end

@interface INVMutableSectionedArray ()

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
    NSUInteger sectionIndex = [_sections indexOfObject:firstHalf];

    INVMutableSectionedArraySection *toInsert = [INVMutableSectionedArraySection new];
    INVMutableSectionedArraySection *secondHalf = [INVMutableSectionedArraySection new];

    toInsert.array = array;
    secondHalf.array = firstHalf.array;

    NSUInteger firstRangeStart = firstHalf.range.location;
    NSUInteger firstRangeEnd = adjustedIndex + 1;

    NSUInteger secondRangeStart = adjustedIndex + 1;
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

    [_sections addObject:section];
}

- (void)removeObjectsInArray:(NSArray *)otherArray
{
    [_sections removeObjectsAtIndexes:[_sections indexesOfObjectsPassingTest:^BOOL(INVMutableSectionedArraySection *section,
                                                                                 NSUInteger _, BOOL *__) {
        return [section.array isEqual:otherArray];
    }]];
}

- (NSUInteger)rawCount
{
    NSUInteger count = 0;
    for (INVMutableSectionedArraySection *section in _sections) {
        count += [section range].length;
    }

    return count;
}

- (NSUInteger)count
{
    return [self rawCount];
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

@end
