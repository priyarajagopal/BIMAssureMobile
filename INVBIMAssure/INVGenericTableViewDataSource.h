//
//  INVGenericDataSource.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/27/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

typedef void (^INV_CellConfigurationBlock)(id cell, id cellData, NSIndexPath* indexPath);

@interface INVGenericTableViewDataSource : NSObject <UITableViewDataSource>
-(id)initWithFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController;

-(void)registerCellWithIdentifier:(NSString*)cellIdentifier configureBlock:(INV_CellConfigurationBlock) configBlock forIndexPath:(NSIndexPath*)indexPath;
-(void)registerCellWithIdentifierForAllIndexPaths:(NSString*)cellIdentifier configureBlock:(INV_CellConfigurationBlock) configBlock ;


@end
