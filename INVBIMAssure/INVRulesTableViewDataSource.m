//
//  INVRulesTableViewDataSource.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRulesTableViewDataSource.h"
#import "INVRuleInstanceTableViewCell.h"


@interface INVRulesTableViewDataSource () <INVRuleInstanceTableViewCellStateDelegate>
@property (nonatomic,strong)INV_CellConfigurationBlock cellConfigBlock;
@property (nonatomic,strong)NSString* cellIdentifier;
@property (nonatomic,strong)NSFetchedResultsController* fetchedResultsController;
@property (nonatomic,strong) NSMutableSet *indexPathsOfOpenCells;
@property (nonatomic,weak) UITableView* tableView;
@end

@implementation INVRulesTableViewDataSource

-(id)initWithFetchedResultsController:(NSFetchedResultsController*)resultsController forTableView:(UITableView*)tableView {
    self = [super init];
    if (self) {
        self.fetchedResultsController = resultsController;
        self.indexPathsOfOpenCells = [[NSMutableSet alloc]initWithCapacity:0];
        self.tableView = tableView;
    }
    return self;
}

-(id)initWithFetchedResultsController:(NSFetchedResultsController*)resultsController {
    return [self initWithFetchedResultsController:resultsController forTableView:nil];
}

-(void)registerCellWithIdentifierForAllIndexPaths:(NSString*)cellIdentifier configureBlock:(INV_CellConfigurationBlock) configBlock {
    self.cellIdentifier = cellIdentifier;
    self.cellConfigBlock = configBlock;
}

-(void)registerCellWithIdentifier:(NSString*)cellIdentifier configureBlock:(INV_CollectionCellConfigurationBlock) configBlock forIndexPath:(NSIndexPath*)indexPath {
#warning This method is unsupported
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   INVRuleSet* ruleSet = self.fetchedResultsController.fetchedObjects[section];
    return ruleSet.ruleInstances.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.fetchedObjects.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    INVRuleSet* ruleSet = self.fetchedResultsController.fetchedObjects[section];
    return ruleSet.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    INVRuleInstanceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    cell.stateDelegate = self;
    id cellData = self.fetchedResultsController.fetchedObjects[indexPath.section];
    INV_CellConfigurationBlock matchBlock = self.cellConfigBlock;
    
    if (matchBlock) {
        matchBlock(cell,cellData,indexPath);
    }
    if ([self.indexPathsOfOpenCells containsObject:indexPath]) {
        [cell openCell];
    }
    return cell;
}


#pragma INVRuleInstanceTableViewCellStateDelegate

- (void)cellDidOpen:(UITableViewCell *)cell {
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.indexPathsOfOpenCells addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell {
    [self.indexPathsOfOpenCells removeObject:[self.tableView indexPathForCell:cell]];
}

@end
