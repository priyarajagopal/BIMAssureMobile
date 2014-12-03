//
//  INVRunRulesTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.


// TODO: All ruleset related logic will go away when we move to rule instances only model. So lot of the (untidy) code will become obsolete.

#import "INVRunRulesTableViewController.h"
#import "INVRunRuleSetHeaderView.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 60;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;

@interface INVRunRulesTableViewController ()<UITableViewDataSource,UITableViewDelegate,INVRunRuleSetHeaderViewActionDelegate>
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic, strong) INVRuleSetMutableArray  ruleSets;
@property (nonatomic, strong) NSMutableSet*  selectedRuleInstanceIds;
@property (nonatomic, strong) NSMutableSet*  selectedRuleSetIds;
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
        cell.accessoryView = [[UIImageView alloc]initWithImage:[self selectedImage]];
    }
    else {
        cell.accessoryView = [[UIImageView alloc]initWithImage:[self deselectedImage]];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return DEFAULT_HEADER_HEIGHT;
}

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
    
    NSNumber* ruleSetId = ruleSet.ruleSetId;
    if ([self.selectedRuleSetIds containsObject:ruleSetId]) {
        __block NSInteger indexOfRuleSet = NSNotFound ;
        __block INVRuleSet* ruleSet = nil;
        [self.ruleSets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ruleSet = obj;
            if ([ruleSet.ruleSetId isEqualToNumber:ruleSetId]) {
                indexOfRuleSet = idx;
                *stop = YES;
            }
        }];
        [self.selectedRuleSetIds removeObject:ruleSetId];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexOfRuleSet] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    INVRuleSet* ruleSet = self.ruleSets[section];
    
    __block INVRunRuleSetHeaderView* headerView ;
    NSArray* objects = [[NSBundle bundleForClass:[self class]]loadNibNamed:@"INVRunRuleSetHeaderView" owner:nil options:nil];
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[INVRunRuleSetHeaderView class]]) {
            headerView = obj;
            *stop = YES;
        }
    }];
    headerView.actionDelegate = self;
    headerView.ruleSetNameLabel.text = ruleSet.name;
    headerView.ruleSetId = ruleSet.ruleSetId;
    if ([self.selectedRuleSetIds containsObject:ruleSet.ruleSetId]) {
        [headerView.runRuleSetToggleButton setSelected:YES];
     }
    else {
        [headerView.runRuleSetToggleButton setSelected:NO];
    }
    return headerView;
}

#pragma mark - server side

-(void)fetchRuleSetIdsForFile {
    [self.globalDataManager.invServerClient  getAllRuleSetsForFile:self.fileMasterId WithCompletionBlock:^(INVEmpireMobileError *error) {
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


-(void)runRuleInstances {
#warning For now ignoring rulesets and only executing on per rule instance basis. Hoping for a better API to combine them
    __block NSNumber* ruleInstanceId;
  
    [self.selectedRuleInstanceIds enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        ruleInstanceId = obj;
        NSLog(@"Will execure rule Instance %@",ruleInstanceId);
        [self.globalDataManager.invServerClient  executeRuleInstance:ruleInstanceId againstFileVersionId:self.fileVersionId againstModel:self.modelId withCompletionBlock:^(INVEmpireMobileError *error) {
            [self.hud hide:YES];
            if (!error) {
                NSLog(@"%s. Success",__func__);
            }
            else {
#warning May need to show a message if one or more fail....
                NSLog(@"%s. Error:%@",__func__,error);
            }
        }];

  
    }];

}

#pragma mark - INVRunRuleSetHeaderViewActionDelegate
-(void)onRuleSetToggled:(INVRunRuleSetHeaderView*)sender {
    NSNumber* tappedRuleSetId = sender.ruleSetId;
    return [self updateRuleSetEntryWithId:tappedRuleSetId];
}

-(void)updateRuleSetEntryWithId:(NSNumber*)ruleSetId {
    
    __block NSInteger indexOfRuleSet = NSNotFound ;
    __block INVRuleSet* ruleSet = nil;
    [self.ruleSets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ruleSet = obj;
        if ([ruleSet.ruleSetId isEqualToNumber:ruleSetId]) {
            indexOfRuleSet = idx;
            *stop = YES;
        }
    }];
    BOOL ruleSetEnabled = YES;
    if ([self.selectedRuleSetIds containsObject:ruleSetId]) {
        ruleSetEnabled = NO;
    }
    
    [ruleSet.ruleInstances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleInstance* ruleInstance = obj;
        NSNumber* ruleInstanceId = ruleInstance.ruleInstanceId;
        if (ruleSetEnabled) {
            if (![self.selectedRuleInstanceIds containsObject:ruleInstanceId]) {
                [self.selectedRuleInstanceIds addObject:ruleInstanceId];
            }
        }
        else {
            if ([self.selectedRuleInstanceIds containsObject:ruleInstanceId]) {
                [self.selectedRuleInstanceIds removeObject:ruleInstanceId];
            }
        }
        
    }];
    
    if ([self.selectedRuleSetIds containsObject:ruleSetId]) {
        [self.selectedRuleSetIds removeObject:ruleSetId];
    }
    else {
        [self.selectedRuleSetIds addObject:ruleSetId];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexOfRuleSet] withRowAnimation:UITableViewRowAnimationAutomatic];

}

-(NSInteger)indexOfRuleSet:(NSNumber*)ruleSetId {
    __block NSInteger indexOfRuleSet = NSNotFound ;
    __block INVRuleSet* ruleSet = nil;
    [self.ruleSets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ruleSet = obj;
        if ([ruleSet.ruleSetId isEqualToNumber:ruleSetId]) {
            indexOfRuleSet = idx;
            *stop = YES;
        }
    }];
    return indexOfRuleSet;
}

#pragma mark - Navigation

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

-(NSMutableSet*)selectedRuleSetIds {
    if (!_selectedRuleSetIds) {
        _selectedRuleSetIds = [[NSMutableSet alloc]initWithCapacity:0];
    }
    return _selectedRuleSetIds;

}

-(UIImage*)selectedImage{
    FAKFontAwesome *selectedIcon = [FAKFontAwesome checkCircleIconWithSize:30];
    [selectedIcon setAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    return [selectedIcon imageWithSize:CGSizeMake(30, 30)];
}



-(UIImage*)deselectedImage {
    FAKFontAwesome *deselectedIcon = [FAKFontAwesome circleOIconWithSize:30];
    [deselectedIcon setAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return [deselectedIcon imageWithSize:CGSizeMake(30, 30)];
}


#pragma mark - helpers
-(void)updateRuleSetsFromServer {
    NSArray* rulesetIdsInFile = [self.rulesManager ruleSetIdsForFile:self.fileMasterId];
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

#pragma mark - UIEvent Handlers

- (IBAction)onRunRulesSelected:(UIButton *)sender {
     [self runRuleInstances];
}
@end
