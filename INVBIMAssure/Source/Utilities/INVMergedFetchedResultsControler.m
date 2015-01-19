//
//  INVMergedFetchResultsControler.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVMergedFetchedResultsControler.h"

@interface INVMergedFetchedResultsControler()

@property NSMutableArray *resultsControllers;

@end

@implementation INVMergedFetchedResultsControler

-(id) init {
    if (self = [super init]) {
        _resultsControllers = [NSMutableArray new];
    }
    
    return self;
}

-(void) addFetchedResultsController:(NSFetchedResultsController *)resultsController {
    [_resultsControllers addObject:resultsController];
}

-(void) removeFetchedResultsController:(NSFetchedResultsController *)resultsController {
    [_resultsControllers removeObject:resultsController];
}

-(NSArray *) allFetchedResultsControllers {
    return [_resultsControllers copy];
}


-(BOOL) performFetch:(NSError *__autoreleasing *)error {
    for (NSFetchedResultsController *resultsController in _resultsControllers) {
        if (![resultsController performFetch:error]) {
            return NO;
        }
    }
    
    return YES;
}

-(NSArray *) fetchedObjects {
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSFetchedResultsController *resultsController in _resultsControllers) {
        [results addObjectsFromArray:resultsController.fetchedObjects];
    }
    
    return [results copy];
}

-(NSArray *) sections {
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSFetchedResultsController *resultsController in _resultsControllers) {
        [results addObjectsFromArray:resultsController.sections];
    }
    
    return [results copy];
}

-(NSInteger) sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex {
    return sectionIndex;
}

-(id) objectAtIndexPath:(NSIndexPath *)indexPath {
    // Find the proper section
    id<NSFetchedResultsSectionInfo> section = [self.sections objectAtIndex:indexPath.section];
    if ([section numberOfObjects] < indexPath.row) {
        [NSException raise:NSRangeException format:@"Index path row %i out of range (0...%i)", indexPath.row, [section numberOfObjects]];
    }
    
    return [section objects][indexPath.row];
}

-(NSIndexPath *) indexPathForObject:(id)object {
    return nil;
}

@end
