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
typedef void (^INV_HeaderConfigurationBlock)(id headerView, id headerData, NSInteger section);

@interface INVGenericTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic,readonly)NSFetchedResultsController* fetchedResultsController; // Alternative to using explicit data arrays
@property (nonatomic,readonly,weak) UITableView* tableView;


-(id)initWithFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController forTableView:(UITableView*)tableView;
-(id)initWithDataArray:(NSArray*)dataArray forSection:(NSInteger)section forTableView:(UITableView*)tableView;

-(void)updateWithDataArray:(NSArray*)updatedDataArray forSection:(NSInteger)section;

-(void)registerCellWithIdentifierForAllIndexPaths:(NSString*)cellIdentifier configureBlock:(INV_CellConfigurationBlock) configBlock ;
-(void)registerCellWithIdentifier:(NSString*)cellIdentifier configureBlock:(INV_CellConfigurationBlock) configBlock forSection:(NSInteger)section;
-(void)registerCellWithIdentifier:(NSString*)cellIdentifier configureBlock:(INV_CellConfigurationBlock) configBlock forIndexPath:(NSIndexPath*)indexPath;

-(CGFloat)heightOfRowContentAtIndexPath:(NSIndexPath*)indexPath ;
@end