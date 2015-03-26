//
//  INVRuleDefinitionsTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/25/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleDefinitionsTableViewController.h"
#import "INVRuleDefinitionTableViewCell.h"
#import "INVBlockUtils.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;

@interface INVRuleDefinitionsTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) INVAnalysesManager *analysesManager;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, readwrite) NSFetchedResultsController *dataResultsController;

@property (nonatomic) NSMutableDictionary *selectedRules;
@property IBOutlet UIBarButtonItem *saveButtonItem;

- (IBAction)onSaveRuleDefinitons:(id)sender;

@end

@implementation INVRuleDefinitionsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"SELECT_RULE_TEMPLATES", nil);

    UINib *nib = [UINib nibWithNibName:@"INVRuleDefinitionTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"RuleDefinitionCell"];

    self.selectedRules = [NSMutableDictionary new];

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
    
    self.saveButtonItem.enabled = NO;
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

- (void)onRefreshControlSelected:(id)event
{
    [self fetchListOfRuleDefinitions];
}

- (void)onSaveRuleDefinitons:(id)sender
{
    [self showLoadProgress];

    [self.globalDataManager.invServerClient addToAnalysis:self.analysisId
                                        ruleDefinitionIds:[self.selectedRules allKeys]
                                      withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                          INV_ALWAYS:
                                              [self.hud hide:YES];

                                          INV_SUCCESS:
                                              [self performSegueWithIdentifier:@"unwind" sender:nil];

                                          INV_ERROR:
                                              INVLogError(@"%@", error);

                                              UIAlertController *errorController = [[UIAlertController alloc]
                                                  initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_DEFINITION_SAVE", nil)];

                                              [self presentViewController:errorController animated:YES completion:nil];
                                      }];
}

#pragma mark - server side
- (void)fetchListOfRuleDefinitions
{
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }

    [self.globalDataManager.invServerClient
        getAllRuleDefinitionsForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
            INV_ALWAYS:
                [self.refreshControl endRefreshing];
                [self.hud hide:YES];

            INV_SUCCESS:
                [self.selectedRules removeAllObjects];
                [self.tableView reloadData];

            INV_ERROR:
                INVLogError(@"%@", error);

                UIAlertController *errController = [[UIAlertController alloc]
                    initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_DEFINITION_LOAD", nil), error.code.integerValue];
                [self presentViewController:errController animated:YES completion:nil];
        }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVRule *rule = [self.dataResultsController objectAtIndexPath:indexPath];

    if (self.selectedRules[rule.ruleId]) {
        [self.selectedRules removeObjectForKey:rule.ruleId];
    }
    else {
        self.selectedRules[rule.ruleId] = rule;
    }

    self.saveButtonItem.enabled = self.selectedRules.count > 0;
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
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
                
                cell.checked = self.selectedRules[rule.ruleId] != nil;
                cell.ruleDefinition = rule;

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
