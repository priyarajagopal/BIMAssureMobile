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


@interface INVRulesListViewController ()
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)INVRulesTableViewDataSource* dataSource;
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

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.dataSource = self.dataSource;
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
    self.dataSource = [[INVRulesTableViewDataSource alloc]initWithFetchedResultsController:self.dataResultsController];
    INV_CellConfigurationBlock cellConfigurationBlock = ^(INVRuleInstanceTableViewCell *cell,id ruleSetManagedObject,NSIndexPath* indexPath){
        INVRuleSet* ruleSet = [MTLManagedObjectAdapter modelOfClass:[INVRuleSet class] fromManagedObject:ruleSetManagedObject error:nil];
        NSArray* ruleInstances = ruleSet.ruleInstances;
        NSInteger cellRow = indexPath.row;
        if (ruleInstances && ruleInstances.count >= cellRow) {
            INVRuleInstance* ruleInstance  = [ruleInstances objectAtIndex:indexPath.row];
            cell.name.text = ruleInstance.ruleName;
            cell.overview.text = ruleInstance.overview;
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


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#warning show details of rule instance
}


#pragma mark - Navigation
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


#pragma mark - accessor

-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.rulesManager.fetchRequestForRuleSets managedObjectContext:self.rulesManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    }
    return  _dataResultsController;
}



@end
