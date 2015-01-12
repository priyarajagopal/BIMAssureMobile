//
//  INVGenericDataSource.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/27/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVGenericTableViewDataSource.h"

static const NSInteger DEFAULT_SECTION_INDEX = 0;
static const NSInteger DEFAULT_ROW_INDEX = 0;
static const NSInteger DEFAULT_CELL_HEIGHT = 100;

typedef NSDictionary* INVCellContentDictionary;
typedef NSDictionary* INVHeaderContentDictionary;

/**
 Keys for INVCellContentDictionary
 */
const static NSString* INV_CellContextIndexPath = @"IndexPath";
const static NSString* INV_CellContextConfigBlock = @"ConfigBlock";
const static NSString* INV_CellContextIdentifier = @"Identifier";
const static NSString* INV_CellContextConfigBlockExtended = @"ConfigBlockWithIndexPath";

const static NSString* INV_HeaderContextSection  = @"section";
const static NSString* INV_HeaderContextConfigBlock = @"ConfigBlock";
const static NSString* INV_HeaderContextIdentifier = @"Identifier";


@interface INVGenericTableViewDataSource ()

@property (nonatomic,strong)NSMutableArray* headerConfigContextArray; // array of INVHeaderContentDictionary objects
@property (nonatomic,readwrite)NSFetchedResultsController* fetchedResultsController; // Alternative to using explicit data arrays
@property (nonatomic,strong)NSMutableDictionary* dataDictionary; // dictionary of section=>array of data elements
@property (nonatomic,strong)NSMutableDictionary* cellConfigDictionary; // dictionary of section=>array of INVCellContentDictionary objects
@property (nonatomic,readwrite,weak) UITableView* tableView;
@end

@implementation INVGenericTableViewDataSource

-(id)initWithFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController forTableView:(UITableView*)tableView{
    self = [super init];
    if (self) {
         self.fetchedResultsController = fetchedResultsController;
         dispatch_async(dispatch_get_main_queue(), ^{
            [self.fetchedResultsController performFetch:nil];
         });
        
         self.cellConfigDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
         self.tableView = tableView;
    }
    return self;
}

-(id)initWithDataArray:(NSArray*)dataArray forSection:(NSInteger)section forTableView:(UITableView *)tableView{
    self = [super init];
    if (self) {
        self.dataDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
        self.cellConfigDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
        self.tableView = tableView;
        if (section == NSNotFound) {
            section = DEFAULT_SECTION_INDEX;
        }
        [self updateWithDataArray:dataArray forSection:section];
    }
    return self;
}

-(void)updateWithDataArray:(NSArray*)updatedDataArray forSection:(NSInteger)section{
    if (section == NSNotFound) {
        section = DEFAULT_SECTION_INDEX;
    }
    self.dataDictionary[@(section)] = [updatedDataArray copy];

}

-(void)registerCellWithIdentifier:(NSString*)cellIdentifier configureBlock:(INV_CellConfigurationBlock) configBlock forSection:(NSInteger)section {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:DEFAULT_ROW_INDEX inSection:section];
    [self registerCellWithIdentifier:cellIdentifier configureBlock:configBlock forIndexPath:indexPath];
}

-(void)registerCellWithIdentifierForAllIndexPaths:(NSString*)cellIdentifier configureBlock:(INV_CellConfigurationBlock) configBlock {
    [self registerCellWithIdentifier:cellIdentifier configureBlock:configBlock forIndexPath:[NSIndexPath indexPathForRow:DEFAULT_ROW_INDEX inSection:DEFAULT_SECTION_INDEX]];
}

-(void)registerCellWithIdentifier:(NSString*)cellIdentifier configureBlock:(INV_CellConfigurationBlock) configBlock forIndexPath:(NSIndexPath*)indexPath {
    INVCellContentDictionary content = @{INV_CellContextIdentifier:cellIdentifier,INV_CellContextIndexPath:indexPath,INV_CellContextConfigBlock:configBlock};
    NSMutableArray* cellContentForSection  = self.cellConfigDictionary[@(indexPath.section)];
    if (!cellContentForSection) {
        cellContentForSection = [[NSMutableArray alloc]initWithCapacity:0];
    }
    [cellContentForSection addObject:content];
    self.cellConfigDictionary[@(indexPath.section)] = cellContentForSection;
}

-(CGFloat)heightOfRowContentAtIndexPath:(NSIndexPath*)indexPath{
    __block INVCellContentDictionary cellContext;
    
    NSArray* cellContextsForSection = self.cellConfigDictionary[@(indexPath.section)];
    if (!cellContextsForSection) {
        cellContextsForSection = self.cellConfigDictionary[@(DEFAULT_SECTION_INDEX)];
    }
    if (cellContextsForSection.count == 1)
    {
        cellContext = cellContextsForSection[0];
    }
    else {
        [cellContextsForSection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            cellContext = obj;
            NSIndexPath* indexPathEntry = cellContext[INV_CellContextIndexPath];
            if ([indexPathEntry isEqual:indexPath]) {
                *stop = YES;
            }
        }];
    }
    if (cellContext) {
        NSString* matchIdentifier = cellContext[INV_CellContextIdentifier];
        id cell = [self.tableView dequeueReusableCellWithIdentifier:matchIdentifier];
        if (cell) {
            [self configureCell:cell atIndexPath:indexPath withCellContext:cellContext];
            [cell layoutIfNeeded];
            CGSize size = [((UITableViewCell*)cell).contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
            return size.height + 10;
        }
        
    }
    return DEFAULT_CELL_HEIGHT;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataDictionary) {
        NSArray* numRows = self.dataDictionary[@(section)];
        return numRows.count;
    }
    else if (self.fetchedResultsController) {
        id<NSFetchedResultsSectionInfo> objectInSection = self.fetchedResultsController.sections[section];
        return objectInSection.numberOfObjects;
    }
    else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataDictionary) {
         return self.dataDictionary.count;
    }
    else if (self.fetchedResultsController){
        return self.fetchedResultsController.sections.count;
    }
    else {
        return 0;
    }
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block INVCellContentDictionary cellContext;
    
    NSArray* cellContextsForSection = self.cellConfigDictionary[@(indexPath.section)];
    if (!cellContextsForSection) {
        cellContextsForSection = self.cellConfigDictionary[@(DEFAULT_SECTION_INDEX)];
    }
    if (cellContextsForSection.count == 1)
    {
        cellContext = cellContextsForSection[0];
    }
    else {
        [cellContextsForSection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            cellContext = obj;
            NSIndexPath* indexPathEntry = cellContext[INV_CellContextIndexPath];
            if ([indexPathEntry isEqual:indexPath]) {
                *stop = YES;
            }
        }];
    }
    if (cellContext) {
        NSString* matchIdentifier = cellContext[INV_CellContextIdentifier];
        id cell = [tableView dequeueReusableCellWithIdentifier:matchIdentifier];
        [self configureCell:cell atIndexPath:indexPath withCellContext:cellContext];
        return cell;
    }
    return nil;
}

#pragma mark - helper
-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath withCellContext:(INVCellContentDictionary)cellContext{
        id cellData = nil;
        if (self.dataDictionary) {
            NSArray* dataArray = self.dataDictionary[@(indexPath.section)];
            cellData = dataArray[indexPath.row];
        }
        else {
            cellData = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        INV_CellConfigurationBlock matchBlock = cellContext[INV_CellContextConfigBlock];
        
        if (matchBlock) {
            matchBlock(cell,cellData,indexPath);
        }

}

@end
