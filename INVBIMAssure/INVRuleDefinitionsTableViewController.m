//
//  INVRuleDefinitionsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/25/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleDefinitionsTableViewController.h"
#import "INVRuleInstanceTableViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;

@interface INVRuleDefinitionsTableViewController ()
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic,strong)INVGenericTableViewDataSource* dataSource;
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,copy)NSNumber* selectedRuleId;
@property (nonatomic,copy)NSString* selectedRuleName;
@end

@implementation INVRuleDefinitionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"SELECT_RULE_TEMPLATES", nil);
    self.rulesManager = self.globalDataManager.invServerClient.rulesManager;
    
    [self setupTableViewDataSource];
    
    self.clearsSelectionOnViewWillAppear = YES;

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];
    [self fetchListOfRuleDefinitions];
}


-(void)setupTableViewDataSource {
    self.dataSource = [[INVGenericTableViewDataSource alloc]initWithFetchedResultsController:self.dataResultsController];
      INV_CellConfigurationBlock cellConfigurationBlock = ^(UITableViewCell *cell,INVRule* rule,NSIndexPath* indexPath){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = rule.ruleName;
        cell.detailTextLabel.text = rule.overview;

      };
#warning Use custom table view cell
    [self.dataSource registerCellWithIdentifierForAllIndexPaths:@"RuleDefinitionCell" configureBlock:cellConfigurationBlock];
    self.tableView.dataSource = self.dataSource;
}

#pragma mark - UIEvent handler
-(IBAction)done:(UIStoryboardSegue*)segue {
    
}

#pragma mark - server side
-(void)fetchListOfRuleDefinitions {
    [self.globalDataManager.invServerClient getAllRuleDefinitionsForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
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


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* ruleDefnCell = [tableView cellForRowAtIndexPath:indexPath];
    
    INVRule* rule = [self.dataResultsController objectAtIndexPath:indexPath];
    self.selectedRuleId = rule.ruleId;
    self.selectedRuleName = ruleDefnCell.textLabel.text;
    [self performSegueWithIdentifier:@"CreateRuleInstanceSegue" sender:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"CreateRuleInstanceSegue"]) {
        INVRuleInstanceTableViewController* ruleInstanceTVC = (INVRuleInstanceTableViewController*)segue.destinationViewController;
        ruleInstanceTVC.ruleId = self.selectedRuleId;
        ruleInstanceTVC.ruleSetId = self.ruleSetId;
        ruleInstanceTVC.ruleName = self.selectedRuleName;
        
    }
}



#pragma mark - accessor

-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.rulesManager.fetchRequestForRules managedObjectContext:self.rulesManager.managedObjectContext sectionNameKeyPath:@"ruleName" cacheName:nil];
    }
    return  _dataResultsController;
}

@end
