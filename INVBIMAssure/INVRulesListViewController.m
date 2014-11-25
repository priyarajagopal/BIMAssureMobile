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
#import "INVRuleSetManageFilesContainerViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;


@interface INVRulesListViewController () <INVRuleInstanceTableViewCellActionDelegate,INVRuleSetTableViewHeaderViewAcionDelegate>
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVRulesTableViewDataSource* dataSource;
@property (nonatomic,strong) NSMutableSet *cellsCurrentlyEditing;
@property (nonatomic,assign) NSNumber* selectedRuleInstanceId;
@property (nonatomic,assign) NSNumber* selectedRuleSetId;
@property (nonatomic,strong)UIAlertController* deletePromptAlertController;
@property (nonatomic,strong)INVRuleInstanceTableViewCell* selectedRowInstanceCell;
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
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    self.cellsCurrentlyEditing = [[NSMutableSet alloc]initWithCapacity:0];
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;

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
                [self logRulesToConsole];
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

-(void)deleteSelectedRuleInstance {
    [self.globalDataManager.invServerClient deleteRuleInstanceForId:self.selectedRuleInstanceId WithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                [self logRulesToConsole];
                [self removeSelectedRowFromTableView];

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
-(void)onViewRuleTappedFor:(INVRuleInstanceTableViewCell*)sender {
    INVRuleInstanceTableViewCell* ruleInstanceCell = (INVRuleInstanceTableViewCell*)sender;
    self.selectedRuleInstanceId = ruleInstanceCell.ruleInstanceId;
    self.selectedRuleSetId = ruleInstanceCell.ruleSetId;
    self.selectedRowInstanceCell = ruleInstanceCell;
    [self performSegueWithIdentifier:@"RuleInstanceViewSegue" sender:self];
}

-(void)onDeleteRuleTappedFor:(INVRuleInstanceTableViewCell*)sender {
    INVRuleInstanceTableViewCell* ruleInstanceCell = (INVRuleInstanceTableViewCell*)sender;
    self.selectedRuleInstanceId = ruleInstanceCell.ruleInstanceId;
    self.selectedRuleSetId = ruleInstanceCell.ruleSetId;
    self.selectedRowInstanceCell = ruleInstanceCell;
     [self showDeletePromptAlert];
    
}

-(void)showDeletePromptAlert {
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.deletePromptAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction* proceedAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"DELETE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self deleteSelectedRuleInstance];
    }];
  
    self.deletePromptAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ARE_YOU_SURE", nil) message:NSLocalizedString(@"DELETE_THE_SELECTED_RULE", nil) preferredStyle:UIAlertControllerStyleAlert];
    [self.deletePromptAlertController addAction:cancelAction];
    [self.deletePromptAlertController addAction:proceedAction];
    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil]setTintColor:[UIColor grayColor]];
    
    [self presentViewController:self.deletePromptAlertController animated:YES completion:^{
        
    }];
}



-(void)removeSelectedRowFromTableView {
    NSIndexPath *indexPathOfCellToDelete = [self.tableView indexPathForCell:self.selectedRowInstanceCell];
    [self.tableView deleteRowsAtIndexPaths:@[indexPathOfCellToDelete] withRowAnimation:UITableViewRowAnimationAutomatic];
    
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
-(void)onManageFilesTapped:(INVRuleSetTableViewHeaderView*)sender {
    INVRuleSetTableViewHeaderView* headerView  =  (INVRuleSetTableViewHeaderView*)sender;
    self.selectedRuleSetId = headerView.ruleSetId;
    [self performSegueWithIdentifier:@"RuleSetFilesSegue" sender:self];
}

-(void)onAddRuleInstanceTapped:(INVRuleSetTableViewHeaderView*)sender {
    INVRuleSetTableViewHeaderView* headerView  =  (INVRuleSetTableViewHeaderView*)sender;
    self.selectedRuleSetId = headerView.ruleSetId;
    [self performSegueWithIdentifier:@"AddRuleInstanceSegue" sender:self];

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
        INVRuleSetManageFilesContainerViewController* rulesetFilesTVC = segue.destinationViewController;
        rulesetFilesTVC.ruleSetId = self.selectedRuleSetId;
        rulesetFilesTVC.projectId = self.projectId;
    }
    if ([segue.identifier isEqualToString:@"AddRuleInstanceSegue"]) {
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

#pragma mark - helpers
-(void)logRulesToConsole {
    [self.dataResultsController.fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleSet* ruleSet = obj;
        [ruleSet.ruleInstances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"Rule Instance for ruleset $%@ is %@\n",ruleSet.ruleSetId, obj);
        }];
    }];
}

@end
