//
//  INVRunRulesTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRunRulesTableViewController.h"

static const NSInteger INDEX_ROW_RULESET = 0;
static const NSInteger DEFAULT_CELL_HEIGHT = 80;

@interface INVRunRulesTableViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)INVRulesManager* rulesManager;
//@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
//@property (nonatomic,strong) NSNumber* selectedRuleInstanceId;
//@property (nonatomic,strong) NSNumber* selectedRuleSetId;
@property (nonatomic, strong) INVRuleSetMutableArray  ruleSets;
@property (nonatomic, strong) NSMutableSet*  selectedRuleInstanceIds;
@property (nonatomic, strong) UIImageView* selectedImageView;
@property (nonatomic, strong) UIImageView* deselectedImageView;
@end

@implementation INVRunRulesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"SELECT_RULES_TO_RUN", nil);
    self.rulesManager = self.globalDataManager.invServerClient.rulesManager;
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
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
    [self fetchRuleSetIdsForFile];
}


#pragma mark - UITableViewDataSource
#warning See if we can move the data source out into a separate object
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    INVRuleSet* ruleSet = self.ruleSets[section];
    return ruleSet.ruleInstances.count ;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.ruleSets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    INVRuleSet* ruleSet = self.ruleSets[indexPath.section];
    
    NSArray* ruleInstances = ruleSet.ruleInstances;
    INVRuleInstance* ruleInstance  = [ruleInstances objectAtIndex:indexPath.row];
    NSNumber* ruleInstanceId = ruleInstance.ruleInstanceId;
    cell = [tableView dequeueReusableCellWithIdentifier:@"RuleSetCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RuleSetCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView setTintColor:[UIColor darkGrayColor]];
    }
    cell.textLabel.text = ruleInstance.ruleName;
    cell.detailTextLabel.text = ruleInstance.overview;
    if ([self.selectedRuleInstanceIds containsObject:ruleInstanceId]) {

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    


    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    INVRuleSet* ruleSet = self.ruleSets[section];
    return ruleSet.name;
  
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    INVRuleSet* ruleSet = self.ruleSets[indexPath.section];
    INVRuleInstance* ruleInstance = ruleSet.ruleInstances[indexPath.row];
    NSNumber* ruleInstanceId = ruleInstance.ruleInstanceId;
    if ([self.selectedRuleInstanceIds containsObject:ruleInstanceId]) {
        [self.selectedRuleInstanceIds removeObject:ruleInstanceId];
     }
    else {
        [self.selectedRuleInstanceIds addObject:ruleInstanceId];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - server side

-(void)fetchRuleSetIdsForFile {
    [self.globalDataManager.invServerClient  getAllRuleSetsForFile:self.fileId WithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud hide:YES];
        if (!error) {
            [self updateRuleSetsFromServer ];
            [self.tableView reloadData];
        }
        else {
#warning - display error
        }
    }];
}
/*

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
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

*/


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
}

-(IBAction)done:(UIStoryboardSegue*) segue {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



#pragma mark - accessor
-(NSMutableSet*)selectedRuleInstanceIds {
    if (!_selectedRuleInstanceIds) {
        _selectedRuleInstanceIds = [[NSMutableSet alloc]initWithCapacity:0];
    }
    return _selectedRuleInstanceIds;
}

-(INVRuleSetMutableArray)ruleSets {
    if (!_ruleSets) {
        _ruleSets = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _ruleSets;
}

-(UIImageView*)selectedImageView {
    if (!_selectedImageView) {
        
    }
    return _selectedImageView;
}

-(UIImageView*)deselectedImageView {
    if (!_deselectedImageView) {
        
    }
    return _deselectedImageView;
}

/*
-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        NSFetchRequest* fetchRequest = self.rulesManager.fetchRequestForRuleSets;
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.rulesManager.fetchRequestForRuleSets managedObjectContext:self.rulesManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        NSPredicate* fetchPredicate = [NSPredicate predicateWithFormat:@"projectId==%@",self.projectId ];
        [fetchRequest setPredicate:fetchPredicate];
        
    }
    return  _dataResultsController;
}
*/

#pragma mark - helpers
-(void)updateRuleSetsFromServer {
    NSArray* rulesetIdsInFile = [self.rulesManager ruleSetIdsForFile:self.fileId];
    INVRuleSetMutableArray ruleSetsAssociatedWithFile = [[self.rulesManager ruleSetsForIds:rulesetIdsInFile]mutableCopy];
    self.ruleSets = ruleSetsAssociatedWithFile;
   
}
-(void)logRulesToConsole {
    [self.ruleSets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleSet* ruleSet = obj;
        [ruleSet.ruleInstances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"Rule Instance for ruleset $%@ is %@\n",ruleSet.ruleSetId, obj);
        }];
    }];
}

@end
