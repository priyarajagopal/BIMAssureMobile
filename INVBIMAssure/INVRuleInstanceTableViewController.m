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

static const NSInteger SECTION_RULEINSTANCEDETAILS = 0;
static const NSInteger SECTION_RULEINSTANCEACTUALPARAM = 1;

static const NSInteger DEFAULT_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_OVERVIEW_CELL_HEIGHT = 175;

static const NSInteger FIRST_ROW = 0;
static const NSInteger FIRST_SECTION = SECTION_RULEINSTANCEDETAILS;

/**
 Dictionary of Name-Value pairs corresponding to the actual parameters. The supported keys are  INV_ActualParamName and INV_ActualParamValue
 */
typedef NSDictionary* INV_ActualParamKeyValuePair;
static NSString* INV_ActualParamName = @"Name";
static NSString* INV_ActualParamValue = @"Value";

@interface INVRuleInstanceTableViewController () <INVRuleInstanceActualParamTableViewCellDelegate>
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic,strong)NSMutableArray* ruleInstanceActualParams; // Array of {INV_ActualParamName,INV_ActualParamValue} pair objects (convenience for generating table views)
@property (nonatomic,strong)INVRule* ruleDefinition;
@property (nonatomic,strong)INVRuleInstance* ruleInstance;
@property (nonatomic,strong)INVGenericTableViewDataSource* dataSource;
@property (nonatomic,strong)NSDictionary* ruleProperties;
#warning editBarButton unused at this time. May choose to have explicit editButton
@property (nonatomic, strong)UIBarButtonItem* editBarButton;
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
    [self.hud show:YES];
    [self fetchRuleInstance];
}


-(void)setupTableViewDataSource {
    // The rule details other than the rule params
    NSArray* ruleInfoArray = self.ruleInstance?@[self.ruleInstance]:[NSArray array];
    if (!self.ruleInstance) {
        self.dataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:ruleInfoArray forSection:SECTION_RULEINSTANCEDETAILS];
    }
    
    INV_CellConfigurationBlock cellConfigurationBlockForRuleOverview = ^(INVRuleInstanceOverviewTableViewCell *cell,INVRuleInstance* ruleInstance ,NSIndexPath* indexPath ){
        cell.ruleName.text = ruleInstance.ruleName;
        cell.ruleDescription.text = ruleInstance.overview;
        cell.delegate = self;
    };
    [self.dataSource registerCellWithIdentifierForAllIndexPaths:@"RuleInstanceOverviewTVC" configureBlock:cellConfigurationBlockForRuleOverview];
    [self.dataSource registerCellWithIdentifier:@"RuleInstanceOverviewTVC" configureBlock:cellConfigurationBlockForRuleOverview forSection:SECTION_RULEINSTANCEDETAILS];
    
    // The actual params
    [self.dataSource updateWithDataArray:self.ruleInstanceActualParams forSection:SECTION_RULEINSTANCEACTUALPARAM];
    INV_CellConfigurationBlock cellConfigurationBlock = ^(INVRuleInstanceActualParamTableViewCell *cell,NSDictionary* KVPair ,NSIndexPath* indexPath ){
        cell.ruleInstanceKey.text = KVPair[INV_ActualParamName];
        cell.ruleInstanceValue.text = KVPair[INV_ActualParamValue];
        cell.delegate = self;
    };
    [self.dataSource registerCellWithIdentifier:@"RuleInstanceDetailCell" configureBlock:cellConfigurationBlock forSection:SECTION_RULEINSTANCEACTUALPARAM];
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
        self.ruleInstance = [self.globalDataManager.invServerClient.rulesManager ruleInstanceForRuleInstanceId:self.ruleInstanceId forRuleSetId:self.ruleSetId];
        NSArray* ruleInfoArray = self.ruleInstance?@[self.ruleInstance]:[NSArray array];

        [self.dataSource updateWithDataArray:ruleInfoArray forSection:SECTION_RULEINSTANCEDETAILS];
        
#warning If unlikely case that matchingRuleInstance was not fetched from the server due to any reason when this view was loaded , fetch it
        INVRuleInstanceActualParamDictionary ruleInstanceActualParam = self.ruleInstance.actualParameters;
        
        [self transformRuleInstanceParamsToArray:ruleInstanceActualParam];
        [self.dataSource updateWithDataArray:self.ruleInstanceActualParams forSection:SECTION_RULEINSTANCEACTUALPARAM];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchRuleDefinitionForRuleId:self.ruleInstance.accountRuleId];
        });
    }
    [self.hud hide:YES];
    [self.tableView reloadData];
 //   [self setupTableFooter];
}


-(void)fetchRuleDefinitionForRuleId:(NSNumber*)ruleId {
    if (!self.ruleInstanceId) {
        NSLog(@"%s. Cannot fetch rule instance definition  RuleInstanceId %@",__func__,self.ruleInstanceId);
    }
    else {
        [self.globalDataManager.invServerClient getRuleDefinitionForRuleId:ruleId WithCompletionBlock:^(INVEmpireMobileError *error) {
            self.ruleDefinition = [self.globalDataManager.invServerClient.rulesManager ruleDefinitionForRuleId:ruleId];
            INVRuleFormalParam* ruleFormalParam = self.ruleDefinition.formalParams;
            self.ruleProperties = ruleFormalParam.properties;

        }];
    }
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
-(NSMutableArray*)ruleInstanceActualParams {
    if (!_ruleInstanceActualParams) {
        _ruleInstanceActualParams = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _ruleInstanceActualParams;
}

#ifdef _SUPPORT_EDIT_BUTTON_NOTFULLYWORKING_
-(UIBarButtonItem*)editBarButton {
    if (!_editBarButton) {
        _editBarButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"EDIT",nil) style:UIBarButtonItemStyleDone target:self action:@selector(onEditRuleInstanceTapped:)];
    }
    return _editBarButton;
    
}
#endif

-(UIBarButtonItem*)saveBarButton {
    if (!_saveBarButton) {
        _saveBarButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"SAVE",nil) style:UIBarButtonItemStyleDone target:self action:@selector(onSaveRuleInstanceTapped:)];
        
    }
    return _saveBarButton;
}

#pragma mark - UIEventHandler
#ifdef _SUPPORT_EDIT_BUTTON_NOTFULLYWORKING_
- (IBAction)onEditRuleInstanceTapped:(UIBarButtonItem *)sender {
    if (sender == self.editBarButton) {
        [self.navigationBar.topItem setRightBarButtonItem:self.saveBarButton];
        [self makeFirstResponderTextFieldAtCellIndexPath:[NSIndexPath indexPathForRow:FIRST_ROW inSection:FIRST_SECTION]];
    }
}

#endif
- (IBAction)onSaveRuleInstanceTapped:(UIBarButtonItem *)sender {
    if (sender == self.saveBarButton) {
        [self.saveBarButton setEnabled:NO];
        
        [self resignFirstTextInputResponder];
        
        if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleInstanceValue)]) {
              [self onRuleInstanceActualParamUpdated:(INVRuleInstanceActualParamTableViewCell*)self.ruleInstanceCellBeingEdited];
            
        }
        else if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleName)]) {
            
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            INVRuleInstanceActualParamDictionary actualParam = [self transformRuleInstanceArrayToRuleInstanceParams:self.ruleInstanceActualParams];
            [self.globalDataManager.invServerClient modifyRuleInstanceForRuleInstanceId:self.ruleInstanceId forRuleId:self.ruleInstance.accountRuleId inRuleSetId:self.ruleSetId withRuleName:self.ruleInstance.ruleName andDescription:self.ruleInstance.overview andActualParameters:actualParam WithCompletionBlock:^(INVEmpireMobileError *error) {
                if (error) {
#warning show error alert
                    NSLog (@"%s. Error %@",__func__,error);
                }
            }];
           });
#ifdef _SUPPORT_EDIT_BUTTON_NOTFULLYWORKING_

       [self.navigationBar.topItem setRightBarButtonItem:self.editBarButton];
#endif
        
     }
}


#pragma mark - INVRuleInstanceOverviewTableViewCellDelegate
-(void)onRuleInstanceOverviewUpdated:(INVRuleInstanceOverviewTableViewCell*)sender {
    
}
-(void)onBeginEditingRuleInstanceOverviewField:(INVRuleInstanceOverviewTableViewCell*)sender {
    [self.saveBarButton setEnabled:YES];
    self.ruleInstanceCellBeingEdited = sender;
}

-(void)onRuleInstanceActualParamUpdated:(INVRuleInstanceActualParamTableViewCell*)sender {
    
    // Set next cell as responder
    INVRuleInstanceActualParamTableViewCell* editedCell = sender;
    __block NSInteger index = NSNotFound;
    NSDictionary* actualParam = @{INV_ActualParamName:editedCell.ruleInstanceKey.text,INV_ActualParamValue:editedCell.ruleInstanceValue.text};
    [self.ruleInstanceActualParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* KVPair = obj;
        
        NSString* currValue = KVPair[INV_ActualParamName];
        if ([currValue isEqualToString:editedCell.ruleInstanceKey.text]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index != NSNotFound) {
        [self.ruleInstanceActualParams replaceObjectAtIndex:index withObject:actualParam];
    }
    /*
    if ([self.ruleInstanceCellBeingEdited.ruleInstanceValue isFirstResponder] && (self.ruleInstanceActualParams.count > index +1 ) ) {
        [self makeFirstResponderTextFieldAtCellIndexPath:[NSIndexPath indexPathForRow:index+1 inSection:SECTION_RULEINSTANCEACTUALPARAM]];
    }
     */
}

-(void)onBeginEditingRuleInstanceActualParamField:(INVRuleInstanceActualParamTableViewCell*)sender {
    [self.saveBarButton setEnabled:YES];
    self.ruleInstanceCellBeingEdited = sender;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_RULEINSTANCEDETAILS) {
        return DEFAULT_OVERVIEW_CELL_HEIGHT;
    }
    else if (indexPath.section == SECTION_RULEINSTANCEACTUALPARAM) {
        return DEFAULT_CELL_HEIGHT;
    }
    return DEFAULT_CELL_HEIGHT;
}

#pragma mark - helper
// Usused at this time
-(void)makeFirstResponderTextFieldAtCellIndexPath:(NSIndexPath*)indexPath {
    INVRuleInstanceActualParamTableViewCell* cell = (INVRuleInstanceActualParamTableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    self.ruleInstanceCellBeingEdited = cell;
 //   [self.ruleInstanceCellBeingEdited.ruleInstanceValue becomeFirstResponder];
}

-(void)resignFirstTextInputResponder {
    if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleInstanceValue)]) {
        [((INVRuleInstanceActualParamTableViewCell*) self.ruleInstanceCellBeingEdited).ruleInstanceValue resignFirstResponder];
    }
    else if ([self.ruleInstanceCellBeingEdited respondsToSelector:@selector(ruleName)]) {
        if ([((INVRuleInstanceOverviewTableViewCell*) self.ruleInstanceCellBeingEdited).ruleName isFirstResponder]) {
            [((INVRuleInstanceOverviewTableViewCell*) self.ruleInstanceCellBeingEdited).ruleName resignFirstResponder];
        }
        else  if ([((INVRuleInstanceOverviewTableViewCell*) self.ruleInstanceCellBeingEdited).ruleDescription isFirstResponder]) {
            [((INVRuleInstanceOverviewTableViewCell*) self.ruleInstanceCellBeingEdited).ruleDescription resignFirstResponder];
        }
    }
}
-(NSString*)ruleInstanceForId:(NSNumber*)ruleInstanceId {
    /*
     INVRuleSetMutableArray members = self.accountManager.accountMembership;
     NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId==%@",userId];
     NSArray* matches = [members filteredArrayUsingPredicate:predicate];
     if (matches && matches.count) {
     INVMembership* member = matches[0];
     return member.email;
     }
     */
    return nil;
}


-(void)transformRuleInstanceParamsToArray:(INVRuleInstanceActualParamDictionary)actualParamDict{
    __block NSDictionary* actualParam;
    [actualParamDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        actualParam = @{INV_ActualParamName:key,INV_ActualParamValue:obj};
        [self.ruleInstanceActualParams addObject:actualParam];
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

-(void) setupTableFooter {
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    NSInteger heightOfTableViewCells = numberOfRows * DEFAULT_CELL_HEIGHT;
    
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.tableView.frame) + heightOfTableViewCells, CGRectGetWidth (self.tableView.frame), CGRectGetHeight(self.tableView.frame)-(heightOfTableViewCells + CGRectGetMinY(self.tableView.frame)))];
    self.tableView.tableFooterView = view;
}


@end
