//
//  INVMergedFetchResultsControler.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVMergedFetchedResultsControler : NSFetchedResultsController

- (void)addFetchedResultsController:(NSFetchedResultsController *)resultsController;
- (void)removeFetchedResultsController:(NSFetchedResultsController *)resultsController;

- (NSArray *)allFetchedResultsControllers;

@end
