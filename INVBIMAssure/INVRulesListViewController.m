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
static const NSInteger DEFAULT_CELL_HEIGHT = 50;


@interface INVRulesListViewController () <INVRuleInstanceTableViewCellActionDelegate>
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVRulesTableViewDataSource* dataSource;
@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;
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
            cell.name.text = ruleInstance.ruleName;
            cell.overview.text = ruleInstance.overview;
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - INVRuleInstanceTableViewActionDelegate
-(void)onEditRuleTapped {
    NSLog (@"%s",__func__);
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


#pragma mark - Navigation
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction* ruleInstanceAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"EDIT",nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"Pop a modal");
    }];
    return @[ruleInstanceAction];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark - accessor

-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.rulesManager.fetchRequestForRuleSets managedObjectContext:self.rulesManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    }
    return  _dataResultsController;
}



@end
