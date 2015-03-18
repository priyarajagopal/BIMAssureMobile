//
//  INVRuleDefinitionsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/25/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleDefinitionsTableViewController.h"
#import "INVRuleDefinitionTableViewCell.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;

@interface INVRuleDefinitionsTableViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) INVAnalysesManager *analysesManager;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, readwrite) NSFetchedResultsController *dataResultsController;
@property (nonatomic, copy) NSNumber *selectedRuleId;
@property (nonatomic, copy) NSString *selectedRuleName;
@end

@implementation INVRuleDefinitionsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"SELECT_RULE_TEMPLATES", nil);

    UINib *nib = [UINib nibWithNibName:@"INVRuleDefinitionTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"RuleDefinitionCell"];

    self.tableView.dataSource = self.dataSource;
    self.clearsSelectionOnViewWillAppear = YES;

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
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
    [self fetchListOfRuleDefinitions];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.analysesManager = nil;
    self.tableView.dataSource = nil;
    self.dataSource = nil;
    self.dataResultsController = nil;
}

#pragma mark - UIEvent handler
- (IBAction)done:(UIStoryboardSegue *)segue
{
}

- (void)onRefreshControlSelected:(id)event
{
    [self fetchListOfRuleDefinitions];
}

#pragma mark - server side
- (void)fetchListOfRuleDefinitions
{
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }
    [self.globalDataManager.invServerClient
        getAllRuleDefinitionsForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            else {
                [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
            }

            if (!error) {
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            else {
                UIAlertController *errController = [[UIAlertController alloc]
                    initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_DEFINITION_LOAD", nil), error.code.integerValue];
                [self presentViewController:errController animated:YES completion:nil];
            }
        }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVRuleDefinitionTableViewCell *ruleDefnCell =
        (INVRuleDefinitionTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];

    INVRule *rule = [self.dataResultsController objectAtIndexPath:indexPath];
    self.selectedRuleId = rule.ruleId;
    self.selectedRuleName = rule.overview;
    [self performSegueWithIdentifier:@"CreateRuleInstanceSegue" sender:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type
{
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"CreateRuleInstanceSegue"]) {
        INVRuleInstanceTableViewController *ruleInstanceTVC =
            (INVRuleInstanceTableViewController *) segue.destinationViewController;
        ruleInstanceTVC.ruleId = self.selectedRuleId;
        ruleInstanceTVC.analysesId = self.analysisId;
        ruleInstanceTVC.ruleName = self.selectedRuleName;
        ruleInstanceTVC.delegate = self.createRuleInstanceDelegate;
    }
}

#pragma mark - helpers
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];
}

#pragma mark - accessor
- (INVGenericTableViewDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[INVGenericTableViewDataSource alloc] initWithFetchedResultsController:self.dataResultsController
                                                                                 forTableView:self.tableView];
        INV_CellConfigurationBlock cellConfigurationBlock =
            ^(INVRuleDefinitionTableViewCell *cell, INVRule *rule, NSIndexPath *indexPath) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.ruleDescription.text = rule.overview;

            };
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"RuleDefinitionCell" configureBlock:cellConfigurationBlock];
    }
    return _dataSource;
}
- (INVAnalysesManager *)analysesManager
{
    if (!_analysesManager) {
        _analysesManager = self.globalDataManager.invServerClient.analysesManager;
    }
    return _analysesManager;
}

- (NSFetchedResultsController *)dataResultsController
{
    if (!_dataResultsController) {
        NSFetchRequest *fetchRequest = self.analysesManager.fetchRequestForRules;
        _dataResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:self.analysesManager.managedObjectContext
                                                  sectionNameKeyPath:@"ruleId"
                                                           cacheName:nil];
        [_dataResultsController setDelegate:self];
        NSError *dbError = nil;
        [_dataResultsController performFetch:&dbError];
        if (dbError) {
            INVLogError(@"Perform fetch failed with %@", dbError);

            _dataResultsController = nil;
        }
    }
    return _dataResultsController;
}

@end
