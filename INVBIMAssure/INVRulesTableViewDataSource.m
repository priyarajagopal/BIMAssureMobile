//
//  INVRulesTableViewDataSource.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRulesTableViewDataSource.h"



@interface INVRulesTableViewDataSource ()
@property (nonatomic,strong)INV_CellConfigurationBlock cellConfigBlock;
@property (nonatomic,strong)NSString* cellIdentifier;
@property (nonatomic,strong)NSFetchedResultsController* fetchedResultsController;
@end

@implementation INVRulesTableViewDataSource

-(id)initWithFetchedResultsController:(NSFetchedResultsController*)resultsController {
    self = [super init];
    if (self) {
        self.fetchedResultsController = resultsController;
    }
    return self;
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

    id cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    id cellData = self.fetchedResultsController.fetchedObjects[indexPath.section];
    INV_CellConfigurationBlock matchBlock = self.cellConfigBlock;
    
    if (matchBlock) {
        matchBlock(cell,cellData,indexPath);
    }
    
    return cell;
}


@end
