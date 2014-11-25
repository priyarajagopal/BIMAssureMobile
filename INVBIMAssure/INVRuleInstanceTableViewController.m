//
//  INVRuleInstanceTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewController.h"
#import "INVRuleInstanceActualParamTableViewCell.h"
#import "INVRuleInstanceOverviewTableViewCell.h"
#import "INVRuleInstanceNameTableViewCell.h"

static const NSInteger SECTION_RULEINSTANCEDETAILS = 0;
static const NSInteger SECTION_RULEINSTANCEACTUALPARAM = 1;
static const NSInteger ROW_RULEINSTANCEDETAILS_NAME = 0;
static const NSInteger ROW_RULEINSTANCEDETAILS_OVERVIEW = 1;

static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_OVERVIEW_CELL_HEIGHT = 175;

/**
 Dictionary of Name-Value pairs corresponding to the actual parameters. The supported keys are  INV_ActualParamName and INV_ActualParamValue
 */
typedef NSDictionary* INV_ActualParamKeyValuePair;
static NSString* INV_ActualParamName = @"Name";
static NSString* INV_ActualParamValue = @"Value";

@interface INVRuleInstanceTableViewController () <INVRuleInstanceActualParamTableViewCellDelegate,INVRuleInstanceOverviewTableViewCellDelegate>
@property (nonatomic,strong)INVGenericTableViewDataSource* dataSource;
@property (nonatomic,strong)INVRulesManager* rulesManager;

@property (nonatomic,strong)NSMutableArray* intermediateRuleInstanceActualParams; // Array of INV_ActualParamKeyValuePair objects transformed from the array params dictionary fetched from server
@property (nonatomic,strong)NSString* intermediateRuleOverview;

// rule definition unused at this time. Eventually use
@property (nonatomic,strong)INVRule* ruleDefinition;
// rule properties unused at this time
@property (nonatomic,strong)NSDictionary* ruleProperties;

@property (nonatomic, strong)UIBarButtonItem* saveBarButton;
@property (nonatomic, weak) UITableViewCell* ruleInstanceCellBeingEdited;

@end

@implementation INVRuleInstanceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"GIVE NAME OF RULE INSTANCE HERE", nil);
    self.rulesManager = self.globalDataManager.invServerClient.rulesManager;
    
    UINib* riNib = [UINib nibWithNibName:@"INVRuleInstanceActualParamTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:riNib forCellReuseIdentifier:@"RuleInstanceDetailCell"];

    UINib* rioNib = [UINib nibWithNibName:@"INVRuleInstanceOverviewTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:rioNib forCellReuseIdentifier:@"RuleInstanceOverviewTVC"];
    
    UINib* rinNib = [UINib nibWithNibName:@"INVRuleInstanceNameTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:rinNib forCellReuseIdentifier:@"RuleInstanceNameTVC"];

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.refreshControl = nil;
    [self setupTableViewDataSource];

    [self.navigationBar.topItem setRightBarButtonItem:self.saveBarButton];
    [self.saveBarButton setEnabled:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
   
    if (self.ruleInstanceId) {
        [self.hud show:YES];
        [self fetchRuleInstance];
    }
    else if (self.ruleId) {
        [self.hud show:YES];
        [self fetchRuleDefinitionForRuleId:self.ruleId];
    }
}


-(void) setupTableFooter {
    
    NSInteger numberOfRowsInActualParamsSection = [self.tableView numberOfRowsInSection:SECTION_RULEINSTANCEACTUALPARAM];
    NSInteger heightOfTableViewCells = numberOfRowsInActualParamsSection * DEFAULT_CELL_HEIGHT;
    
    heightOfTableViewCells += DEFAULT_CELL_HEIGHT + DEFAULT_OVERVIEW_CELL_HEIGHT;
    
    
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.tableView.frame) + heightOfTableViewCells, CGRectGetWidth (self.tableView.frame), CGRectGetHeight(self.tableView.frame)-(heightOfTableViewCells + CGRectGetMinY(self.tableView.frame)))];
    self.tableView.tableFooterView = view;
}

-(void)setupTableViewDataSource {
    
#warning consider refactoring method to smaller ones...too long
    // rule name
    NSIndexPath* indexPathForRuleName = [NSIndexPath indexPathForRow:ROW_RULEINSTANCEDETAILS_NAME inSection:SECTION_RULEINSTANCEDETAILS];
    INVRuleInstance* ruleInstance = [self.globalDataManager.invServerClient.rulesManager ruleInstanceForRuleInstanceId:self.ruleInstanceId forRuleSetId:self.ruleSetId];
    self.intermediateRuleOverview = ruleInstance.overview;
    
    NSArray* ruleInfoArray = ruleInstance?@[ruleInstance.ruleName,self.intermediateRuleOverview]:[NSArray array];
    self.dataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:ruleInfoArray forSection:SECTION_RULEINSTANCEDETAILS];
    
    
    INV_CellConfigurationBlock cellConfigurationBlockForRuleName = ^(INVRuleInstanceNameTableViewCell *cell,NSString* ruleName ,NSIndexPath* indexPath ){
        cell.ruleName.text = ruleName;
        [cell.ruleName setUserInteractionEnabled:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    };
    [self.dataSource registerCellWithIdentifier:@"RuleInstanceNameTVC" configureBlock:cellConfigurationBlockForRuleName forIndexPath:indexPathForRuleName];
    
    // rule overview
    NSIndexPath* indexPathForRuleOverview = [NSIndexPath indexPathForRow:ROW_RULEINSTANCEDETAILS_OVERVIEW inSection:SECTION_RULEINSTANCEDETAILS];

    INV_CellConfigurationBlock cellConfigurationBlockForRuleOverview = ^(INVRuleInstanceOverviewTableViewCell *cell,NSString* overview ,NSIndexPath* indexPath ){
        cell.ruleDescription.text = overview;
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    };
    [self.dataSource registerCellWithIdentifier:@"RuleInstanceOverviewTVC" configureBlock:cellConfigurationBlockForRuleOverview forIndexPath:indexPathForRuleOverview];

    // The actual params if we are editing a rule instance
    if (self.ruleInstanceId ) {
        [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams forSection:SECTION_RULEINSTANCEACTUALPARAM];
        INV_CellConfigurationBlock cellConfigurationBlock = ^(INVRuleInstanceActualParamTableViewCell *cell,NSDictionary* KVPair ,NSIndexPath* indexPath ){
            cell.ruleInstanceKey.text = KVPair[INV_ActualParamName];
            cell.ruleInstanceValue.text = KVPair[INV_ActualParamValue];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        };
        [self.dataSource registerCellWithIdentifier:@"RuleInstanceDetailCell" configureBlock:cellConfigurationBlock forSection:SECTION_RULEINSTANCEACTUALPARAM];
    }
    else {
#warning - Replace INVRuleInstanceActualParamTableViewCell with a generic cell that works across actual and formal
        
        [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams forSection:SECTION_RULEINSTANCEACTUALPARAM];
        INV_CellConfigurationBlock cellConfigurationBlock = ^(INVRuleInstanceActualParamTableViewCell *cell,NSDictionary* KVPair ,NSIndexPath* indexPath ){
            cell.ruleInstanceKey.text = KVPair[INV_ActualParamName];
            cell.ruleInstanceValue.text = KVPair[INV_ActualParamValue];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        };
        [self.dataSource registerCellWithIdentifier:@"RuleInstanceDetailCell" configureBlock:cellConfigurationBlock forSection:SECTION_RULEINSTANCEACTUALPARAM];
    }
    self.tableView.dataSource = self.dataSource;
    
  
}

#pragma mark - server side
-(void)fetchRuleInstance {
    if (!self.ruleSetId || !self.ruleInstanceId) {
        [self.hud hide:YES];
#warning Show an error alert or a default page
        NSLog(@"%s. Cannot fetch rule instance details for RuleSet %@ and RuleInstanceId %@",__func__,self.ruleSetId,self.ruleInstanceId);
    }
    else {
#warning If unlikely case that matchingRuleInstance was not fetched from the server due to any reason when this view was loaded , fetch it

        INVRuleInstance* ruleInstance = [self.globalDataManager.invServerClient.rulesManager ruleInstanceForRuleInstanceId:self.ruleInstanceId forRuleSetId:self.ruleSetId];
        
        self.intermediateRuleOverview = ruleInstance.overview;
        NSArray* ruleInfoArray = ruleInstance?@[ruleInstance.ruleName,self.intermediateRuleOverview]:[NSArray array];
        [self.dataSource updateWithDataArray:ruleInfoArray forSection:SECTION_RULEINSTANCEDETAILS];
        
        INVRuleInstanceActualParamDictionary ruleInstanceActualParam = ruleInstance.actualParameters;
        [self transformRuleInstanceParamsToArray:ruleInstanceActualParam];
        [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams forSection:SECTION_RULEINSTANCEACTUALPARAM];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchRuleDefinitionForRuleId:ruleInstance.accountRuleId];
        });
    }
    [self.hud hide:YES];
    [self.tableView reloadData];
    [self setupTableFooter];
}


-(void)fetchRuleDefinitionForRuleId:(NSNumber*)ruleId {
    if (!ruleId) {
        NSLog(@"%s. Cannot fetch rule  definition for ruleId %@",__func__,ruleId);
    }
    else {
        [self.globalDataManager.invServerClient getRuleDefinitionForRuleId:ruleId WithCompletionBlock:^(INVEmpireMobileError *error) {
            if (!error) {
                self.ruleDefinition = [self.globalDataManager.invServerClient.rulesManager ruleDefinitionForRuleId:ruleId];
                INVRuleFormalParam* ruleFormalParam = self.ruleDefinition.formalParams;
                self.ruleProperties = ruleFormalParam.properties;
                
                [self transformRuleInstanceParamsToArray:self.ruleProperties];
                [self.dataSource updateWithDataArray:self.intermediateRuleInstanceActualParams forSection:SECTION_RULEINSTANCEACTUALPARAM];
            }
            else {
#warning show error alert
            }
            
            [self.hud hide:YES];
            [self.tableView reloadData];
            [self setupTableFooter];

        }];
    }
}

-(void)sendUpdatedRuleInstanceToServer {
    INVRuleInstance* ruleInstance = [self.globalDataManager.invServerClient.rulesManager ruleInstanceForRuleInstanceId:self.ruleInstanceId forRuleSetId:self.ruleSetId];
    
    INVRuleInstanceActualParamDictionary actualParam = [self transformRuleInstanceArrayToRuleInstanceParams:self.intermediateRuleInstanceActualParams];
    [self.globalDataManager.invServerClient modifyRuleInstanceForRuleInstanceId:self.ruleInstanceId forRuleId:ruleInstance.accountRuleId inRuleSetId:self.ruleSetId withRuleName:ruleInstance.ruleName andDescription:self.intermediateRuleOverview andActualParameters:actualParam WithCompletionBlock:^(INVEmpireMobileError *error) {
        if (error) {
#warning show error alert
            NSLog (@"%s. Error %@",__func__,error);
        }
    }];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CancelSegue"]) {
        [self resignFirstTextInputResponder];
    }
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - accessors
-(NSMutableArray*)intermediateRuleInstanceActualParams {
    if (!_intermediateRuleInstanceActualParams) {
        _intermediateRuleInstanceActualParams = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _intermediateRuleInstanceActualParams;
}

-(UIBarButtonItem*)saveBarButton {
    if (!_saveBarButton) {
        _saveBarButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"SAVE",nil) style:UIBarButtonItemStyleDone target:self action:@selector(onSaveRuleInstanceTapped:)];
        
    }
    return _saveBarButton;
}

#pragma mark - UIEventHandler

- (IBAction)onSaveRuleInstanceTapped:(UIBarButtonItem *)sender {
    if (sender == self.saveBarButton) {
        [self.saveBarButton setEnabled:NO];
        
        [self resignFirstTextInputResponder];
        
        [self scrapeTableViewForUpdatedContent];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendUpdatedRuleInstanceToServer];
            });
     }
}



#pragma mark - INVRuleInstanceOverviewTableViewCellDelegate
-(void)onBeginEditingRuleInstanceOverviewField:(INVRuleInstanceOverviewTableViewCell*)sender {
    [self.saveBarButton setEnabled:YES];
    self.ruleInstanceCellBeingEdited = sender;
}

-(void)onRuleInstanceOverviewUpdated:(INVRuleInstanceOverviewTableViewCell*)sender {
    
     // Update the first responder
    [self makeFirstResponderTextFieldAtCellIndexPath:[NSIndexPath indexPathForRow:0 inSection:SECTION_RULEINSTANCEACTUALPARAM]];
}



#pragma mark - INVRuleInstanceActualParamTableViewCellDelegate
-(void)onBeginEditingRuleInstanceActualParamField:(INVRuleInstanceActualParamTableViewCell*)sender {
    [self.saveBarButton setEnabled:YES];
    self.ruleInstanceCellBeingEdited = sender;
}

-(void)onRuleInstanceActualParamUpdated:(INVRuleInstanceActualParamTableViewCell*)sender {
    
      INVRuleInstanceActualParamTableViewCell* editedCell = sender;
    __block NSInteger index = NSNotFound;
    [self.intermediateRuleInstanceActualParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* KVPair = obj;
        
        NSString* currValue = KVPair[INV_ActualParamName];
        if ([currValue isEqualToString:editedCell.ruleInstanceKey.text]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    // 2) update the first responder
    if ([((INVRuleInstanceActualParamTableViewCell*)(self.ruleInstanceCellBeingEdited)).ruleInstanceValue isFirstResponder] ) {
        if (self.intermediateRuleInstanceActualParams.count > index +1 ) {
            [self makeFirstResponderTextFieldAtCellIndexPath:[NSIndexPath indexPathForRow:index+1 inSection:SECTION_RULEINSTANCEACTUALPARAM]];
        }
        if (self.intermediateRuleInstanceActualParams.count == index +1 ) {
            [self resignFirstTextInputResponder];
        }
        
    }
    
}



#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_RULEINSTANCEDETAILS && indexPath.row == 1) {
        return DEFAULT_OVERVIEW_CELL_HEIGHT;
    }
  
    return DEFAULT_CELL_HEIGHT;
}

#pragma mark - helper

-(void)makeFirstResponderTextFieldAtCellIndexPath:(NSIndexPath*)indexPath {
    INVRuleInstanceActualParamTableViewCell* cell = (INVRuleInstanceActualParamTableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    self.ruleInstanceCellBeingEdited = cell;
    if (indexPath.section == SECTION_RULEINSTANCEDETAILS) {
        if (indexPath.row == ROW_RULEINSTANCEDETAILS_NAME) {
             [((INVRuleInstanceNameTableViewCell*)self.ruleInstanceCellBeingEdited).ruleName becomeFirstResponder];
        }
        else {
            [((INVRuleInstanceOverviewTableViewCell*)self.ruleInstanceCellBeingEdited).ruleDescription becomeFirstResponder];
        }
    }
    else if (indexPath.section == SECTION_RULEINSTANCEACTUALPARAM) {
        [((INVRuleInstanceActualParamTableViewCell*)self.ruleInstanceCellBeingEdited).ruleInstanceValue becomeFirstResponder];
    }
  
}

-(void)resignFirstTextInputResponder {
    if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleInstanceValue)]) {
        [((INVRuleInstanceActualParamTableViewCell*) self.ruleInstanceCellBeingEdited).ruleInstanceValue resignFirstResponder];
    }
    else if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleName)]) {
       [((INVRuleInstanceNameTableViewCell*) self.ruleInstanceCellBeingEdited).ruleName resignFirstResponder];
    }
    else if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleDescription)]) {
        [((INVRuleInstanceOverviewTableViewCell*) self.ruleInstanceCellBeingEdited).ruleDescription resignFirstResponder];
    }
    
}


-(void)transformRuleInstanceParamsToArray:(INVRuleInstanceActualParamDictionary)actualParamDict{
    __block NSDictionary* actualParam;
    [actualParamDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        actualParam = @{INV_ActualParamName:key,INV_ActualParamValue:obj};
        [self.intermediateRuleInstanceActualParams addObject:actualParam];
    }];
}

-(INVRuleInstanceActualParamDictionary)transformRuleInstanceArrayToRuleInstanceParams:(NSArray*)actualParamsArray{
    
    __block NSMutableDictionary* actualParam = [[NSMutableDictionary alloc]initWithCapacity:0];
    [actualParamsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* actualDict = obj;
        NSString* key = actualDict[INV_ActualParamName];
        NSString* value = actualDict[INV_ActualParamValue];
        [actualParam setObject:value forKey:key];
        
    }];
    return  actualParam;
}


-(void)scrapeTableViewForUpdatedContent {
    INVRuleInstanceOverviewTableViewCell* overviewCell = (INVRuleInstanceOverviewTableViewCell*) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:ROW_RULEINSTANCEDETAILS_OVERVIEW inSection:SECTION_RULEINSTANCEDETAILS]];
    self.intermediateRuleOverview = overviewCell.ruleDescription.text;
    
     __block NSDictionary* actualParam;
    NSMutableArray* updatedActualParamsArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self.intermediateRuleInstanceActualParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVRuleInstanceActualParamTableViewCell* actualParamCell = (INVRuleInstanceActualParamTableViewCell*) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:SECTION_RULEINSTANCEACTUALPARAM]];
         actualParam = @{INV_ActualParamName:actualParamCell.ruleInstanceKey.text,INV_ActualParamValue:actualParamCell.ruleInstanceValue.text};
        [updatedActualParamsArray addObject:actualParam];
        
    }];
    self.intermediateRuleInstanceActualParams = [NSMutableArray arrayWithArray:updatedActualParamsArray];
    
}

@end
