//
//  INVAnalysisExecutionsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/3/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVAnalysisExecutionsTableViewController.h"
#import "INVRuleInstanceExecutionResultTableViewCell.h"
#import "INVExecutionIssuesTableViewController.h"
#import "EmpireMobileManager/INVRuleInstanceExecution.h"
#import "INVModelTreeIssuesTableViewController.h"

static const NSInteger SECTION_INDEX_RESULTS = 0;
static const NSInteger DEFAULT_CELL_HEIGHT = 100;
static const NSInteger DEFAULT_HEADER_HEIGHT = 50;
static const NSInteger DEFAULT_FOOTER_HEIGHT = 20;

@interface INVAnalysisExecutionsTableViewController ()
@property (nonatomic, strong) INVProjectManager *projectManager;
@property (nonatomic, strong) INVAnalysesManager *analysesManager;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) INVPackage *file;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, assign) NSInteger fetchedFilesExecutionCallbackCount;

@end

@implementation INVAnalysisExecutionsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"EXECUTIONS", nil);

    UINib *reNib =
        [UINib nibWithNibName:@"INVRuleInstanceExecutionResultTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:reNib forCellReuseIdentifier:@"RuleExecutionTVC"];

    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.estimatedSectionHeaderHeight = DEFAULT_HEADER_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initializeTableViewDataSource];
    self.fetchedFilesExecutionCallbackCount = 0;
    [self fetchExecutionsForFilesFromServer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.projectManager = nil;
    self.analysesManager = nil;
    self.dateFormatter = nil;
    self.file = nil;
    self.tableView.dataSource = nil;
    self.dataSource = nil;
}

- (void)initializeTableViewDataSource
{
    self.dataSource = [[INVGenericTableViewDataSource alloc] initWithDataArray:@[
    ] forSection:SECTION_INDEX_RESULTS forTableView:self.tableView];
    INV_CellConfigurationBlock cellConfigurationBlock =
        ^(INVRuleInstanceExecutionResultTableViewCell *cell, INVAnalysisRunResult *execution, NSIndexPath *indexPath) {
            cell.runResult = execution;
            cell.ruleInstanceName.text = execution.ruleName;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            NSString *overView = execution.ruleDescription && execution.ruleDescription.length
                                     ? execution.ruleDescription
                                     : NSLocalizedString(@"DESCRIPTION_UNAVAILABLE", nil);
            cell.ruleInstanceOverview.text = overView;

            NSString *executedAtStr = NSLocalizedString(@"EXECUTED_AT", nil);

            NSString *executedAtWithDateStr =
                [NSString stringWithFormat:@"%@ : %@", executedAtStr, [self.dateFormatter stringFromDate:execution.createdAt]];
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:executedAtWithDateStr];
            [attrString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor darkTextColor]
                               range:NSMakeRange(0, executedAtStr.length - 1)];
            [attrString addAttribute:NSForegroundColorAttributeName
                               value:[UIColor lightGrayColor]
                               range:NSMakeRange(executedAtStr.length, executedAtWithDateStr.length - executedAtStr.length)];
            cell.ruleInstanceExecutionDate.attributedText = attrString;

            UIColor *successColor = [UIColor colorWithRed:63.0 / 255 green:166.0 / 255 blue:125.0 / 255 alpha:1.0];
            UIColor *failColor = [UIColor colorWithRed:212.0 / 255 green:38.0 / 255 blue:58.0 / 255 alpha:1.0];
            UIColor *otherColor = [UIColor darkGrayColor];

            if (execution.status.integerValue == INV_ANALYSISRUN_TYPE_COMPLETED) {
                cell.executionStatus.backgroundColor = successColor;
            }
            else if (execution.status.integerValue == INV_ANALYSISRUN_TYPE_FAILED) {
                cell.executionStatus.backgroundColor = failColor;
            }
            else {
                cell.executionStatus.backgroundColor = otherColor;
            }

            cell.executionStatus.text = [INVEmpireMobileClient analysisRunStatusMap][execution.status];
            cell.numIssues.textColor = otherColor;

            NSString *issuesText = NSLocalizedString(@"ISSUES_UNKNOWN", nil);
            /*
                    if (execution.) {
                        NSDictionary *issueElement = execution.issues[0];
                        NSArray *buildingElements = issueElement[@"buildingElements"];
                        issuesText = [NSString stringWithFormat:@"%@: %ld", NSLocalizedString(@"NUM_ERRORS", nil),
               execution.issues.count];
                        cell.numIssues.textColor = failColor;
                        cell.associatedBuildingElementsWithIssues = buildingElements;

                        [cell.alertIconLabel setHidden:NO];
                    }
                    else

                    {
                        cell.numIssues.textColor = [UIColor colorWithRed:60.0 / 255 green:130.0 / 255 blue:102.0 / 255
               alpha:1.0];
                        [cell.alertIconLabel setHidden:YES];
                        cell.associatedBuildingElementsWithIssues = nil;
                    }
             */
            cell.numIssues.text = issuesText;

        };
    [self.dataSource registerCellWithIdentifierForAllIndexPaths:@"RuleExecutionTVC" configureBlock:cellConfigurationBlock];
    self.tableView.dataSource = self.dataSource;
}

#pragma mark - UITableViewCellDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource heightOfRowContentAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return DEFAULT_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return DEFAULT_FOOTER_HEIGHT;
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#warning Use attributed text for header label
    UILabel *headerLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(tableView.frame), DEFAULT_HEADER_HEIGHT)];

    id<NSFetchedResultsSectionInfo> objectInSection = self.dataResultsController.sections[section];
    [headerLabel setBackgroundColor:[UIColor lightGrayColor]];
    headerLabel.text =
        [NSString stringWithFormat:@"%@ (%lu)", self.file.packageName, (unsigned long) (objectInSection.numberOfObjects)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    return headerLabel;
}
*/

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#define _SERVER_SUPPORT_AVAILABLE_
#ifdef _SERVER_SUPPORT_AVAILABLE_
    INVRuleInstanceExecutionResultTableViewCell *cell =
        (INVRuleInstanceExecutionResultTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    /*
    if (cell.alertIconLabel.isHidden) {
        return;
    }
     */
    [self performSegueWithIdentifier:@"ShowIssuesSegue" sender:self];

#else
    UIAlertController *errController =
        [[UIAlertController alloc] initWithErrorMessage:@"The issues list is not supported in this version!"];
    [self presentViewController:errController animated:YES completion:nil];

#endif
}

#pragma mark - server side

- (void)fetchExecutionsForFilesFromServer
{
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }

    [self.globalDataManager.invServerClient
        getExecutionResultsForAnalysisRun:self.analysisRunId
                      WithCompletionBlock:^(INVAnalysisRunResultsArray response, INVEmpireMobileError *error) {
                          if ([self.refreshControl isRefreshing]) {
                              [self.refreshControl endRefreshing];
                          }
                          else {
                              [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
                          }

                          if (!error) {
                              [self.dataSource updateWithDataArray:response forSection:SECTION_INDEX_RESULTS];
                              [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                                               withObject:nil
                                                            waitUntilDone:NO];
                          }
                          else {
                              UIAlertController *errController = [[UIAlertController alloc]
                                  initWithErrorMessage:NSLocalizedString(@"ERROR_EXECUTION_LOAD", nil),
                                  error.code.integerValue];
                              [self presentViewController:errController animated:YES completion:nil];
                          }
                      }];
}

#pragma mark - UIEvent handler
- (void)onRefreshControlSelected:(id)sender
{
    [self.refreshControl beginRefreshing];
    [self fetchExecutionsForFilesFromServer];
}

#pragma mark - accessor

- (INVAnalysesManager *)analysesManager
{
    if (!_analysesManager) {
        _analysesManager = self.globalDataManager.invServerClient.analysesManager;
    }
    return _analysesManager;
}

- (INVProjectManager *)projectManager
{
    if (!_projectManager) {
        _projectManager = self.globalDataManager.invServerClient.projectManager;
    }
    return _projectManager;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

- (INVPackage *)file
{
    if (!_file) {
        NSPredicate *matchPred = [NSPredicate predicateWithFormat:@"tipId==%@", self.fileVersionId];

        NSArray *packages = [self.projectManager packagesForProjectId:self.projectId];
        NSArray *match = [packages filteredArrayUsingPredicate:matchPred];
        if (match && match.count) {
            _file = match[0];
        }
    }

    return _file;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowIssuesSegue"]) {
        INVRuleInstanceExecutionResultTableViewCell *cell = (INVRuleInstanceExecutionResultTableViewCell *)
            [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            INVModelTreeIssuesTableViewController *executionTVC =
                (INVModelTreeIssuesTableViewController *) ((UINavigationController *) segue.destinationViewController)
                    .topViewController;
            executionTVC.packageVersionId = self.fileVersionId;
            executionTVC.analysisRunId = self.analysisRunId;
            executionTVC.runResult = cell.runResult;
            executionTVC.doNotClearBackground = YES;
        }
    }
}

#pragma mark - helper
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

@end
