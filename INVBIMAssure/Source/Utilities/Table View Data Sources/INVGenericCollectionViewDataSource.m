//
//  INVGenericCollectionViewDataSource.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVGenericCollectionViewDataSource.h"

static const NSInteger DEFAULT_SECTION_INDEX = 0;
static const NSInteger DEFAULT_ROW_INDEX = 0;

typedef NSDictionary* INVCellContentDictionary;

/**
 Keys for INVCellContentDictionary
 */
const static NSString* INV_CellContextIndexPath = @"IndexPath";
const static NSString* INV_CellContextConfigBlock = @"ConfigBlock";
const static NSString* INV_CellContextIdentifier = @"Identifier";


@interface INVGenericCollectionViewDataSource ()
@property (nonatomic,strong)NSMutableArray* cellConfigContextArray; // array of INVCellContentDictionary objects
@property (nonatomic,strong)NSFetchedResultsController* fetchedResultsController;
@end

@implementation INVGenericCollectionViewDataSource

-(id)initWithFetchedResultsController:(NSFetchedResultsController*)resultsController {
    self = [super init];
    if (self) {
        self.fetchedResultsController = resultsController;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fetchedResultsController performFetch:nil];
        });
        self.cellConfigContextArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return self;
}

-(void)registerCellWithIdentifierForAllIndexPaths:(NSString*)cellIdentifier configureBlock:(INV_CollectionCellConfigurationBlock) configBlock {
    [self registerCellWithIdentifier:cellIdentifier configureBlock:configBlock forIndexPath:[NSIndexPath indexPathForRow:DEFAULT_ROW_INDEX inSection:DEFAULT_SECTION_INDEX]];
}

-(void)registerCellWithIdentifier:(NSString*)cellIdentifier configureBlock:(INV_CollectionCellConfigurationBlock) configBlock forIndexPath:(NSIndexPath*)indexPath {
    INVCellContentDictionary content = @{INV_CellContextIdentifier:cellIdentifier,INV_CellContextIndexPath:indexPath,INV_CellContextConfigBlock:configBlock};
    [self.cellConfigContextArray addObject:content];
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section  {
    id<NSFetchedResultsSectionInfo> objectInSection = self.fetchedResultsController.sections[section];
    return objectInSection.numberOfObjects;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView  {
    return self.fetchedResultsController.sections.count;
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __block INVCellContentDictionary cellContext;
    
    if (self.cellConfigContextArray.count == 1)
    {
        cellContext = self.cellConfigContextArray[0];
    }
    else {
        [self.cellConfigContextArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            cellContext = obj;
            NSIndexPath* indexPathEntry = cellContext[INV_CellContextIndexPath];
            if ([indexPathEntry isEqual:indexPath]) {
                *stop = YES;
            }
        }];
    }
    if (cellContext) {
        NSString* matchIdentifier = cellContext[INV_CellContextIdentifier];
        INV_CollectionCellConfigurationBlock matchBlock = cellContext[INV_CellContextConfigBlock];
        id cell = [collectionView dequeueReusableCellWithReuseIdentifier:matchIdentifier forIndexPath:indexPath];
        id cellData = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (matchBlock) {
            matchBlock(cell,cellData,indexPath);
        }
        
        return cell;
    }
    return nil;
}


@end
