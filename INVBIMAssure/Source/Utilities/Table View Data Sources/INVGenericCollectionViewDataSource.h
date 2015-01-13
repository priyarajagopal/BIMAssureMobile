//
//  INVGenericCollectionViewDataSource.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^INV_CollectionCellConfigurationBlock)(id cell, id cellData,NSIndexPath* indexPath);

@interface INVGenericCollectionViewDataSource : NSObject <UICollectionViewDataSource>

-(id)initWithFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController;
-(void)registerCellWithIdentifier:(NSString*)cellIdentifier configureBlock:(INV_CollectionCellConfigurationBlock) configBlock forIndexPath:(NSIndexPath*)indexPath;
-(void)registerCellWithIdentifierForAllIndexPaths:(NSString*)cellIdentifier configureBlock:(INV_CollectionCellConfigurationBlock) configBlock ;

@end
