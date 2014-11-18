//
//  INVRuleInstanceTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewController.h"
#import "INVRuleInstanceDetailTableViewCell.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 50;
/**
 Dictionary of Name-Value pairs corresponding to the actual parameters. The supported keys are  INV_ActualParamName and INV_ActualParamValue
 */
typedef NSDictionary* INV_ActualParamKeyValuePair;
static NSString* INV_ActualParamName = @"Name";
static NSString* INV_ActualParamValue = @"Value";

@interface INVRuleInstanceTableViewController () 
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic,strong)NSMutableArray* ruleInstanceActualParams; // Array of {INV_ActualParamName,INV_ActualParamValue} pair objects
@property (nonatomic,strong)INVGenericTableViewDataSource* dataSource;
@property (nonatomic,strong)NSDictionary* ruleProperties;
@end

@implementation INVRuleInstanceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"GIVE NAME OF RULE INSTANCE HERE", nil);
    self.rulesManager = self.globalDataManager.invServerClient.rulesManager;
    
    UINib* riNib = [UINib nibWithNibName:@"INVRuleInstanceDetailTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:riNib forCellReuseIdentifier:@"RuleInstanceDetailCell"];

    [self setupTableViewDataSource];
    self.tableView.dataSource = self.dataSource;
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.refreshControl = nil;

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
    self.dataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:self.ruleInstanceActualParams];
    INV_CellConfigurationBlock cellConfigurationBlock = ^(INVRuleInstanceDetailTableViewCell *cell,NSDictionary* KVPair ,NSIndexPath* indexPath ){
        cell.ruleInstanceKey.text = KVPair[INV_ActualParamName];
        cell.ruleInstanceValue.text = KVPair[INV_ActualParamValue];
       
    };
    [self.dataSource registerCellWithIdentifierForAllIndexPaths:@"RuleInstanceDetailCell" configureBlock:cellConfigurationBlock];
}

#pragma mark - server side
-(void)fetchRuleInstance {
    if (!self.ruleSetId || !self.ruleInstanceId) {
        [self.hud hide:YES];
#warning Show an error alert or a default page
        NSLog(@"%s. Cannot fetch rule instance details for RuleSet %@ and RuleInstanceId %@",__func__,self.ruleSetId,self.ruleInstanceId);
    }
    else {
        INVRuleInstance* matchingRuleInstance = [self.globalDataManager.invServerClient.rulesManager ruleInstanceForRuleInstanceId:self.ruleInstanceId forRuleSetId:self.ruleSetId];
       
#warning If unlikely case that matchingRuleInstance was not fetched from the server due to any reason when this view was loaded , fetch it
        INVRuleInstanceActualParamDictionary ruleInstanceActualParam = matchingRuleInstance.actualParameters;
        
        [self transformRuleInstanceParamsToArray:ruleInstanceActualParam];
        [self.dataSource updateWithDataArray:self.ruleInstanceActualParams];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchRuleDefinitionForRuleId:matchingRuleInstance.accountRuleId];
        });
    }
    [self.hud hide:YES];
    [self.tableView reloadData];
    [self setupTableFooter];
}


-(void)fetchRuleDefinitionForRuleId:(NSNumber*)ruleId {
    if (!self.ruleInstanceId) {
        NSLog(@"%s. Cannot fetch rule instance definition  RuleInstanceId %@",__func__,self.ruleInstanceId);
    }
    else {
        [self.globalDataManager.invServerClient getRuleDefinitionForRuleId:ruleId WithCompletionBlock:^(INVEmpireMobileError *error) {
            INVRule* rule = [self.globalDataManager.invServerClient.rulesManager ruleDefinitionForRuleId:ruleId];
            INVRuleFormalParam* ruleFormalParam = rule.formalParams;
            self.ruleProperties = ruleFormalParam.properties;

        }];
        
   
    }

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}



#pragma mark - NSFetchedResultsControllerDelegate

#pragma mark - helper
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


-(void)transformRuleInstanceParamsToArray:(INVRuleInstanceActualParamDictionary)formalParamDict{
    __block NSDictionary* actualParam;
    [formalParamDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        actualParam = @{INV_ActualParamName:key,INV_ActualParamValue:obj};
        [self.ruleInstanceActualParams addObject:actualParam];
    }];
}

-(void) setupTableFooter {
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    NSInteger heightOfTableViewCells = numberOfRows * DEFAULT_CELL_HEIGHT;
    
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.tableView.frame) + heightOfTableViewCells, CGRectGetWidth (self.tableView.frame), CGRectGetHeight(self.tableView.frame)-(heightOfTableViewCells + CGRectGetMinY(self.tableView.frame)))];
    self.tableView.tableFooterView = view;
}

#pragma mark - accessors
-(NSMutableArray*)ruleInstanceActualParams {
    if (!_ruleInstanceActualParams) {
        _ruleInstanceActualParams = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _ruleInstanceActualParams;
}


@end
