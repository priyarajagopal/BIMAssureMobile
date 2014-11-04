//
//  INVRulesListViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRulesListViewController.h"
#import "INVRuleInstanceTableViewCell.h"
#import "INVRulesTableViewDataSource.h"
#import "INVRuleInstanceTableViewController.h"
#import "INVRuleSetTableViewHeaderView.h"
#import "INVRuleSetManageFilesTableViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 50;


@interface INVRulesListViewController () <INVRuleInstanceTableViewCellActionDelegate,INVRuleSetTableViewHeaderViewAcionDelegate>
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVRulesTableViewDataSource* dataSource;
@property (nonatomic,strong) NSMutableSet *cellsCurrentlyEditing;
@property (nonatomic,assign) NSNumber* selectedRuleInstanceId;
@property (nonatomic,assign) NSNumber* selectedRuleSetId;
@end

@implementation INVRulesListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"RULES", nil);
    
    self.rulesManager = self.globalDataManager.invServerClient.rulesManager;
    
    [self setupTableViewDataSource];

    UINib* nib = [UINib nibWithNibName:@"INVRuleInstanceTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"RuleInstanceCell"];
/*
    UINib* headerNib = [UINib nibWithNibName:@"INVRuleSetTableViewHeaderView" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:headerNib forHeaderFooterViewReuseIdentifier:@"RuleSetHeaderView"];
 */
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    self.cellsCurrentlyEditing = [[NSMutableSet alloc]initWithCapacity:0];
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self.dataSource;
    self.tableView.allowsSelectionDuringEditing = NO;
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
    [self fetchRuleSets];
}

-(void)setupTableViewDataSource {
    self.dataSource = [[INVRulesTableViewDataSource alloc]initWithFetchedResultsController:self.dataResultsController forTableView:self.tableView];
    INV_CellConfigurationBlock cellConfigurationBlock = ^(INVRuleInstanceTableViewCell *cell,id ruleSetManagedObject,NSIndexPath* indexPath){
        INVRuleSet* ruleSet = [MTLManagedObjectAdapter modelOfClass:[INVRuleSet class] fromManagedObject:ruleSetManagedObject error:nil];
        NSArray* ruleInstances = ruleSet.ruleInstances;
        NSInteger cellRow = indexPath.row;
        if (ruleInstances && ruleInstances.count >= cellRow) {
            INVRuleInstance* ruleInstance  = [ruleInstances objectAtIndex:indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.name.text = ruleInstance.ruleName;
            cell.overview.text = ruleInstance.overview;
            cell.ruleInstanceId = ruleInstance.ruleInstanceId;
            cell.ruleSetId = ruleInstance.ruleSetId;
            cell.actionDelegate = self;
        }
    
    };
    [self.dataSource registerCellWithIdentifierForAllIndexPaths:@"RuleInstanceCell" configureBlock:cellConfigurationBlock];
    self.tableView.dataSource = self.dataSource;
}

#pragma mark - server side
-(void)fetchRuleSets {
    [self.globalDataManager.invServerClient getAllRuleSetsForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                NSLog(@"%s. %@",__func__,self.dataResultsController.fetchedObjects);
                [self.tableView reloadData];
            }
            else {
#warning - display error
            }
            
        }
        else {
#warning - display error
        }
    }];
}


#pragma mark - INVRuleInstanceTableViewActionDelegate
-(void)onViewRuleTappedFor:(id)sender {
    INVRuleInstanceTableViewCell* ruleInstanceCell = (INVRuleInstanceTableViewCell*)sender;
    self.selectedRuleInstanceId = ruleInstanceCell.ruleInstanceId;
    self.selectedRuleSetId = ruleInstanceCell.ruleSetId;
    [self performSegueWithIdentifier:@"RuleInstanceViewSegue" sender:self];
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
#warning  use resuable tableheaderfotter view
     
    INVRuleSet* ruleSet = self.dataResultsController.fetchedObjects[section];
    
    __block INVRuleSetTableViewHeaderView* headerView ;
    NSArray* objects = [[NSBundle bundleForClass:[self class]]loadNibNamed:@"INVRuleSetTableViewHeaderView" owner:nil options:nil];
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[INVRuleSetTableViewHeaderView class]]) {
            headerView = obj;
            *stop = YES;
        }
    }];
    headerView.actionDelegate = self;
    headerView.ruleSetNameLabel.text = ruleSet.name;
    headerView.ruleSetId = ruleSet.ruleSetId;
    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


#pragma mark - INVRuleSetTableViewHeaderViewAcionDelegate
-(void)onManageFilesTapped:(id)sender {
    [self performSegueWithIdentifier:@"RuleSetFilesSegue" sender:self];
}

#pragma mark - Navigation
/*
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction* ruleInstanceAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"EDIT",nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"Pop a modal");
    }];
    return @[ruleInstanceAction];
}
 */

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RuleInstanceViewSegue"]) {
        INVRuleInstanceTableViewController* ruleInstanceTVC = segue.destinationViewController;
        ruleInstanceTVC.ruleInstanceId = self.selectedRuleInstanceId;
        ruleInstanceTVC.ruleSetId = self.selectedRuleSetId;
    }
    if ([segue.identifier isEqualToString:@"RuleSetFilesSegue"]) {
        INVRuleSetManageFilesTableViewController* rulesetFilesTVC = segue.destinationViewController;
        rulesetFilesTVC.ruleSetId = self.selectedRuleSetId;
        rulesetFilesTVC.projectId = self.projectId;
    }
    
}

-(IBAction)done:(UIStoryboardSegue*) segue {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - accessor

-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.rulesManager.fetchRequestForRuleSets managedObjectContext:self.rulesManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    }
    return  _dataResultsController;
}



@end
