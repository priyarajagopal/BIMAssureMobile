//
//  INVRuleDefinitionsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/25/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleDefinitionsTableViewController.h"
#import "INVRuleInstanceTableViewController.h"
#import "INVRuleDefinitionTableViewCell.h"

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
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"SELECT_RULE_TEMPLATES", nil);
    
    UINib* nib = [UINib nibWithNibName:@"INVRuleDefinitionTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"RuleDefinitionCell"];
    
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
    self.tableView.dataSource = self.dataSource;
    [self fetchListOfRuleDefinitions];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.rulesManager = nil;
    self.dataSource = nil;
    self.dataResultsController = nil;
}

#pragma mark - UIEvent handler
-(IBAction)done:(UIStoryboardSegue*)segue {
    
}

#pragma mark - server side
-(void)fetchListOfRuleDefinitions {
    [self showLoadProgress];
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
    INVRuleDefinitionTableViewCell* ruleDefnCell = (INVRuleDefinitionTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    INVRule* rule = [self.dataResultsController objectAtIndexPath:indexPath];
    self.selectedRuleId = rule.ruleId;
    self.selectedRuleName = ruleDefnCell.ruleName.text;
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

#pragma mark - helpers
-(void)showLoadProgress {
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];

}

#pragma mark - accessor
-(INVGenericTableViewDataSource*)dataSource {
    if (!_dataSource) {
        _dataSource = [[INVGenericTableViewDataSource alloc]initWithFetchedResultsController:self.dataResultsController forTableView:self.tableView];
        INV_CellConfigurationBlock cellConfigurationBlock = ^(INVRuleDefinitionTableViewCell *cell,INVRule* rule,NSIndexPath* indexPath){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.ruleName.text = rule.ruleName;
            cell.ruleDescription.text = rule.overview;
            
        };
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"RuleDefinitionCell" configureBlock:cellConfigurationBlock];
    }
    return _dataSource;

}
-(INVRulesManager*)rulesManager {
    if (!_rulesManager) {
        _rulesManager = self.globalDataManager.invServerClient.rulesManager;
    }
    return _rulesManager;
}

-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.rulesManager.fetchRequestForRules managedObjectContext:self.rulesManager.managedObjectContext sectionNameKeyPath:@"ruleId" cacheName:nil];
    }
    return  _dataResultsController;
}

@end
