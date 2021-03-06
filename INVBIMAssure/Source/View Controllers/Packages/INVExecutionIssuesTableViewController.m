//
//  INVExecutionIssuesTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVExecutionIssuesTableViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;
static const NSInteger DEFAULT_SECTION_INDEX = 0;

@interface INVExecutionIssuesTableViewController ()
@property (nonatomic, strong) INVAnalysesManager *analysisManager;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
//@property (nonatomic, strong) INVBuildingElementMutableArray buildingElementDetails;

@property (nonatomic, strong) NSMutableArray *buildingElementDetails;
@end

@implementation INVExecutionIssuesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"BUILDING_ELEMENTS_WITH_ISSUES", nil);

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.estimatedSectionHeaderHeight = DEFAULT_HEADER_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    self.refreshControl = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.dataSource = self.dataSource;
    [self fetchBuildingElementDetailsFromServer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
  //  self.buildingElementDetails = nil;

    self.analysisManager = nil;
    self.buildingElementsWithIssues = nil;
    self.tableView.dataSource = nil;
    self.dataSource = nil;
}
/*

- (void)updateTableViewDataSource
{
    [self.dataSource updateWithDataArray:self.buildingElementDetails forSection:DEFAULT_SECTION_INDEX];
}
*/
#pragma mark - server side
- (void)fetchBuildingElementDetailsFromServer
{
    /*
    [self showLoadProgress];

    [self.buildingElementsWithIssues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

#warning This is for now. When backend changes, this will be an array of NSNumbers corresponding to element Id
        NSDictionary *element = obj;
        NSNumber *elementId = element[@"id"];

        [self.globalDataManager.invServerClient
            fetchBuildingElementDetailsForId:elementId
                         withCompletionBlock:INV_COMPLETION_HANDLER {
                             INV_ALWAYS:
                                 [self.hud hide:YES];

                             INV_SUCCESS : {
                                 INVBuildingElement *buildingElement = [self.buildingManager buildingElementForID:elementId];
                                 if (buildingElement) {
                                     [self.buildingElementDetails addObject:buildingElement];
                                 }

                                 if (idx == self.buildingElementsWithIssues.count - 1) {
                                     [self updateTableViewDataSource];
                                     [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                                                      withObject:nil
                                                                   waitUntilDone:NO];
                                 }
                             }

                             INV_ERROR:
                                 INVLogError(@"%@", error);

                                 UIAlertController *errController = [[UIAlertController alloc]
                                     initWithErrorMessage:NSLocalizedString(@"ERROR_BUILDING_ELEMENT_LOAD", nil),
                                     error.code.integerValue];
                                 [self presentViewController:errController animated:YES completion:nil];
                         }];
    }];
     */
}

#pragma mark - accessor
/*
- (INVGenericTableViewDataSource *)dataSource
{
    if (!_dataSource) {
        if (self.buildingElementsWithIssues) {
            _dataSource = [[INVGenericTableViewDataSource alloc] initWithDataArray:self.buildingElementDetails
                                                                        forSection:DEFAULT_SECTION_INDEX
                                                                      forTableView:self.tableView];
        }
        else {
            _dataSource = [[INVGenericTableViewDataSource alloc] initWithDataArray:@[
            ] forSection:DEFAULT_SECTION_INDEX forTableView:self.tableView];
        }

        INV_CellConfigurationBlock cellConfigurationBlock =
            ^(UITableViewCell *cell, id buildingElement, NSIndexPath *indexPath) {

                cell.textLabel.text = [buildingElement name];
                cell.detailTextLabel.text = @"MORE_DETAILS_OF_ELEMENT_GO_HERE";

            };
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"BuildingElementTVC" configureBlock:cellConfigurationBlock];
    }
    return _dataSource;
}

- (NSArray *)buildingElementDetails
{
    if (!_buildingElementDetails) {
        _buildingElementDetails = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _buildingElementDetails;
}

<<<<<<< HEAD
- (INVBuildingManager *)buildingManager
{
    if (!_buildingManager) {
        _buildingManager = self.globalDataManager.invServerClient.buildingManager;
    }
    return _buildingManager;
}
*/

#pragma mark - helper
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

@end
