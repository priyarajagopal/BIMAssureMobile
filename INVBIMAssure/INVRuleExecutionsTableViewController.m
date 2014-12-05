//
//  INVRuleExecutionsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/3/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleExecutionsTableViewController.h"
#import "INVRuleInstanceExecutionResultTableViewCell.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 100;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;

@interface INVRuleExecutionsTableViewController ()
@property (nonatomic,strong)INVProjectManager* projectManager;
@property (nonatomic,strong)NSDateFormatter* dateFormatter;
@property (nonatomic,strong)INVRulesManager* rulesManager;
@property (nonatomic,strong)INVFileArray files;
@property (nonatomic,strong)INVGenericTableViewDataSource* dataSource;

@end

@implementation INVRuleExecutionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"EXECUTIONS", nil);
    
    UINib* reNib = [UINib nibWithNibName:@"INVRuleInstanceExecutionResultTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:reNib forCellReuseIdentifier:@"RuleExecutionTVC"];

    [self initializeTableViewDataSource];
    self.rulesManager = self.globalDataManager.invServerClient.rulesManager;
    self.projectManager = self.globalDataManager.invServerClient.projectManager;
    
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.estimatedSectionHeaderHeight = DEFAULT_HEADER_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.refreshControl = nil;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    
#warning  Use cached files and executions and then schedule a fetch
    [self fetchFilesFromServer];
}

-(void)updateTableViewDataSource {
    [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger section = idx;
        INVFile* file = obj;
        INVRuleInstanceExecutionArray executions = [self.rulesManager allRuleExecutionsForFileVersion:file.fileId];
        if (executions) {
            [self.dataSource updateWithDataArray:executions forSection:section];
        }
        
    }];
}

-(void)initializeTableViewDataSource {
    
    [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger section = idx;
        if (self.dataSource) {
            [self.dataSource updateWithDataArray:@[] forSection:section];
        }
        else {
            self.dataSource = [[INVGenericTableViewDataSource alloc]initWithDataArray:@[] forSection:section forTableView:self.tableView];
        }
        
    }];
    INV_CellConfigurationBlock cellConfigurationBlock = ^(INVRuleInstanceExecutionResultTableViewCell *cell,INVRuleInstanceExecution* execution,NSIndexPath* indexPath ){
        cell.ruleInstanceName.text = @"RULE INSTANCE NAME GOES HERE";
        cell.ruleInstanceOverview.text = execution.overview;
        
        NSString* executedAtStr = NSLocalizedString(@"EXECUTED_AT", nil);
        
#warning Fix this when server side is fixed
#ifdef _DATEINUTC_
        NSString* executedAtWithDateStr =[NSString stringWithFormat:@"%@ : %@",executedAtStr, [self.dateFormatter stringFromDate:execution.executedAt]];
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]initWithString:executedAtWithDateStr];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, executedAtStr.length-1)];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(executedAtStr.length,executedAtWithDateStr.length-executedAtStr.length)];
        cell.ruleInstanceExecutionDate.attributedText = attrString;
#else
        NSString* executedAtWithDateStr =[NSString stringWithFormat:@"%@ : %@",executedAtStr, execution.executedAt];
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]initWithString:executedAtWithDateStr];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, executedAtStr.length-1)];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(executedAtStr.length,executedAtWithDateStr.length-executedAtStr.length)];
        cell.ruleInstanceExecutionDate.attributedText = attrString;
        
#endif
        
#warning Add colors based on status
        cell.executionStatus.text = execution.status;
        
        NSString* issuesText = NSLocalizedString(@"NO_ISSUES", nil);
        if (execution.issueCount) {
            issuesText = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"NUM_ERRORS", nil),execution.issueCount];
        }
        cell.numIssues.text = issuesText;
        
#warning Change the alert Icon based on issues count.
        
    };
    [self.dataSource registerCellWithIdentifierForAllIndexPaths:@"RuleExecutionTVC" configureBlock:cellConfigurationBlock];
    self.tableView.dataSource = self.dataSource;
}


#pragma mark - UITableViewCellDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource heightOfRowContentAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DEFAULT_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
#warning  Use attributed text for header label
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,0, CGRectGetWidth(tableView.frame), DEFAULT_HEADER_HEIGHT )];
    INVFile* file = self.files[section];
    INVRuleInstanceExecutionArray executions = [self.rulesManager allRuleExecutionsForFileVersion:file.tipId];
    
    headerLabel.text = [NSString stringWithFormat:@"%@ (%lu)",file.fileName, (unsigned long)(executions? executions.count:0)] ;
    
    return headerLabel;
}


#pragma mark - server side
-(void)fetchFilesFromServer {
    [self.globalDataManager.invServerClient getAllFilesForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
         if (!error) {
            self.files = self.projectManager.projectFiles;
            if (!self.dataSource) {
                [self initializeTableViewDataSource];
            }
            else {
                [self updateTableViewDataSource];
            }
            [self fetchExecutionsForFilesFromServer];
        }
        else {
            [self.hud hide:YES];
            
#warning - display error
        }
    }];
}

-(void)fetchExecutionsForFilesFromServer {
    [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        INVFile* file = obj;
        NSInteger section = idx;
        [self.globalDataManager.invServerClient fetchRuleExecutionsForFileVersion:file.tipId withCompletionBlock:^(INVEmpireMobileError *error) {
            [self.hud hide:YES];
            if (!error) {
                INVRuleInstanceExecutionArray executions = [self.rulesManager allRuleExecutionsForFileVersion:file.tipId];
                NSLog(@"%s. section %d. Num executions %d for file Id %d",__func__,section,executions.count,file.tipId);
                [self.dataSource updateWithDataArray:executions forSection:section];
                 
            }
            else {
#warning - display error
            }
            [self.tableView reloadData];
        }];
    }];
    
}

#pragma mark - accessor

-(NSDateFormatter*)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

@end
