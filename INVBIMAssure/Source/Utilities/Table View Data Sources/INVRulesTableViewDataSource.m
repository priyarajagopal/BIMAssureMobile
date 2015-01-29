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
@property (nonatomic, strong) INV_CellConfigurationBlock cellConfigBlock;
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSMutableSet *indexPathsOfOpenCells;
@end

@implementation INVRulesTableViewDataSource

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)resultsController forTableView:(UITableView *)tableView
{
    self = [super initWithFetchedResultsController:resultsController forTableView:tableView];
    if (self) {
        self.indexPathsOfOpenCells = [[NSMutableSet alloc] initWithCapacity:0];
    }
    return self;
}

- (void)registerCellWithIdentifierForAllIndexPaths:(NSString *)cellIdentifier
                                    configureBlock:(INV_CellConfigurationBlock)configBlock
{
    self.cellIdentifier = cellIdentifier;
    self.cellConfigBlock = configBlock;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    INVRuleSet *ruleSet = super.fetchedResultsController.fetchedObjects[section];
    return ruleSet.ruleInstances.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return super.fetchedResultsController.fetchedObjects.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    INVRuleSet *ruleSet = super.fetchedResultsController.fetchedObjects[section];
    return ruleSet.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVRuleInstanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    cell.stateDelegate = self;
    id cellData = self.fetchedResultsController.fetchedObjects[indexPath.section];
    INV_CellConfigurationBlock matchBlock = self.cellConfigBlock;

    if (matchBlock) {
        matchBlock(cell, cellData, indexPath);
    }

    if ([self.indexPathsOfOpenCells containsObject:indexPath]) {
        [cell openCell];
    }
    return cell;
}

#pragma mark - INVRuleInstanceTableViewCellStateDelegate

- (void)cellDidOpen:(UITableViewCell *)cell
{
    NSIndexPath *currentEditingIndexPath = [super.tableView indexPathForCell:cell];
    [self.indexPathsOfOpenCells addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell
{
    [self.indexPathsOfOpenCells removeObject:[super.tableView indexPathForCell:cell]];
}

@end
