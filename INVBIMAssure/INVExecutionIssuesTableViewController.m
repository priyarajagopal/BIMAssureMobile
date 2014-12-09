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
@property (nonatomic,strong)INVBuildingManager* buildingManager;
@property (nonatomic,strong)INVGenericTableViewDataSource* dataSource;
@property (nonatomic,strong) INVBuildingElementMutableArray buildingElementDetails;
@end

@implementation INVExecutionIssuesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"BUILDING_ELEMENTS_WITH_ISSUES", nil);
    
    [self initializeTableViewDataSource];
    self.buildingManager = self.globalDataManager.invServerClient.buildingManager;
    
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.estimatedSectionHeaderHeight = DEFAULT_HEADER_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    self.refreshControl = nil;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    
#warning  Use cached files and executions and then schedule a fetch
    [self fetchBuildingElementDetailsFromServer];
}

-(void)updateTableViewDataSource {
    [self.dataSource updateWithDataArray:self.buildingElementDetails forSection:DEFAULT_SECTION_INDEX];
}

-(void)initializeTableViewDataSource {
    
    if (self.buildingElementsWithIssues) {
        self.dataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:self.buildingElementDetails forSection:DEFAULT_SECTION_INDEX forTableView:self.tableView];
    }
    else {
        self.dataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:@[] forSection:DEFAULT_SECTION_INDEX forTableView:self.tableView];
    }

    INV_CellConfigurationBlock cellConfigurationBlock = ^(UITableViewCell *cell,INVBuildingElement* buildingElement,NSIndexPath* indexPath ){
        
        cell.textLabel.text = buildingElement.name;
        cell.detailTextLabel.text = @"MORE_DETAILS_OF_ELEMENT_GO_HERE";
        
    };
    [self.dataSource registerCellWithIdentifierForAllIndexPaths:@"BuildingElementTVC" configureBlock:cellConfigurationBlock];
    self.tableView.dataSource = self.dataSource;
}

#pragma mark - UITableViewCellDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DEFAULT_HEADER_HEIGHT;
}


#pragma mark - server side
-(void)fetchBuildingElementDetailsFromServer {
    [self.buildingElementsWithIssues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
#warning  This is for now. When backend changes, this will be an array of NSNumbers corresponding to element Id
        NSDictionary* element = obj;
        NSNumber* elementId = element[@"id"];
        
        [self.globalDataManager.invServerClient fetchBuildingElementDetailsForId:elementId withCompletionBlock:^(INVEmpireMobileError *error) {
            [self.hud hide:YES];
            
            if (!error) {
                INVBuildingElement* buildingElement = [self.buildingManager buildingElementForID:elementId];

                [self.buildingElementDetails addObject:buildingElement];
                
#warning  How about loading only after all elements are fetched?
                if (!self.dataSource) {
                    [self initializeTableViewDataSource];
                }
                else {
                    [self updateTableViewDataSource];
                }
                [self.tableView reloadData];
            }
            else {
                
#warning - display error
            }
        }];

    }];
}


#pragma mark - accessor
-(INVBuildingElementMutableArray)buildingElementDetails {
    if (!_buildingElementDetails) {
        _buildingElementDetails = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _buildingElementDetails;
}



@end
