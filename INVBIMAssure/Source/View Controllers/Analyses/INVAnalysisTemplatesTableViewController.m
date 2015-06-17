//
//  INVAnalysisTemplatesViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 5/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisTemplatesTableViewController.h"
#import "INVAnalysisTemplateOverviewTableViewCell.h"
#import "INVAnalysisTemplateDetailsTableViewController.h"

static const NSInteger DEFAULT_CELL_HEIGHT = 80;
static const NSInteger DEFAULT_FETCH_PAGE_SIZE = 20;

@interface INVAnalysisTemplatesTableViewController ()<NSFetchedResultsControllerDelegate,
    INVAnalysisTemplateOverviewTableViewCellDelegate>

@property (nonatomic, strong) INVAnalysesManager *analysesManager;
@property (nonatomic, strong) INVGenericTableViewDataSource *dataSource;
@property (nonatomic, readwrite) NSFetchedResultsController *dataResultsController;
@property (nonatomic) NSMutableDictionary *selectedTemplates;

@property (nonatomic, strong) INVPagingManager *templatesPagingManager;
@property (nonatomic, assign) NSInteger templateCount;

@property IBOutlet UIBarButtonItem *saveButtonItem;

- (IBAction)onSaveAnalysisTemplates:(id)sender;

@end

@implementation INVAnalysisTemplatesTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"SELECT_ANALYSIS_TEMPLATES", nil);

    UINib *nib =
        [UINib nibWithNibName:@"INVAnalysisTemplateOverviewTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"AnalysisTemplateCell"];

    self.selectedTemplates = [NSMutableDictionary new];
    self.refreshControl = nil;

    self.tableView.dataSource = self.dataSource;
    self.clearsSelectionOnViewWillAppear = YES;

    self.tableView.estimatedRowHeight = DEFAULT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.templateCount = 0;
    [self fetchAnalysisTemplateCount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.saveButtonItem.enabled = self.selectedTemplates.count > 0;
}

#pragma mark - UIEvent handler

- (void)onRefreshControlSelected:(id)event
{
    [self fetchListOfAnalysisTemplates];
}

- (void)onSaveAnalysisTemplates:(id)sender
{
    [self showLoadProgress];

    [self.globalDataManager.invServerClient
              addToAnalysis:self.analysisId
        analysisTemplateIds:[self.selectedTemplates allKeys]
        withCompletionBlock:^( INVEmpireMobileError *error) {
            INV_ALWAYS:
                [self.hud hide:YES];

            INV_SUCCESS:
                [self performSegueWithIdentifier:@"unwind" sender:nil];

            INV_ERROR:
                INVLogError(@"%@", error);

                UIAlertController *errorController = [[UIAlertController alloc]
                    initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_ANALYSISTEMPLATE_SAVE", nil)];

                [self presentViewController:errorController animated:YES completion:nil];
        }];
}

#pragma mark - server side
- (void)fetchListOfAnalysisTemplates
{
    [self.globalDataManager.invServerClient
        getAllAnalysisTemplatesForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
            INV_ALWAYS:
                [self.refreshControl endRefreshing];
                [self.hud hide:YES];

            INV_SUCCESS:
                [self.selectedTemplates removeAllObjects];
                [self.tableView reloadData];

            INV_ERROR:
                INVLogError(@"%@", error);

                UIAlertController *errController = [[UIAlertController alloc]
                    initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_ANALYSISTEMPLATE_LOAD", nil), error.code.integerValue];
                [self presentViewController:errController animated:YES completion:nil];
        }];
}

- (void)fetchAnalysisTemplateCount
{
    [self.globalDataManager.invServerClient
        getAnalysisTemplateCountForSignedInAccountWithCompletionBlock:^(INVGenericResponse *response,
                                                                          INVEmpireMobileError *error) {
            if (error) {
                UIAlertController *errController = [[UIAlertController alloc]
                    initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_ANALYSISTEMPLATE_LOAD", nil), error];
                [self presentViewController:errController animated:YES completion:nil];
            }
            else {
                self.templateCount = ((NSNumber *) response.response).integerValue;
                [self fetchAnalysisTemplateFromZeroOffset];
            }
        }];
}

- (void)fetchAnalysisTemplateFromCurrentOffset
{
    INVLogDebug();

    SEL sel = @selector(getAllAnalysisTemplatesForSignedInAccountWithOffset:pageSize:WithCompletionBlock:);

    [self.templatesPagingManager fetchPageFromCurrentOffsetUsingSelector:sel
                                                                onTarget:self.globalDataManager.invServerClient
                                                 withAdditionalArguments:nil];
}

- (void)fetchAnalysisTemplateFromZeroOffset
{
    INVLogDebug();
    if (![self.refreshControl isRefreshing]) {
        [self showLoadProgress];
    }

    [self.templatesPagingManager resetOffset];

    [self fetchAnalysisTemplateFromCurrentOffset];
}

#pragma mark - INVPagingManagerDelegate

- (void)onFetchedDataAtOffset:(NSInteger)offset pageSize:(NSInteger)size withError:(INVEmpireMobileError *)error
{
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];

    if (!error) {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    else {
        if (error.code.integerValue != INV_ERROR_CODE_NOMOREPAGES) {
            UIAlertController *errController = [[UIAlertController alloc]
                initWithErrorMessage:NSLocalizedString(@"ERROR_RULE_ANALYSISTEMPLATE_LOAD", nil), error.code.integerValue];
            [self presentViewController:errController animated:YES completion:nil];
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowAnalysisTemplateDetailsSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVLogDebug(@"Will fetch next batch. self.dataResultsController.fetchedObjects.count %ld, indexPath.row:%ld",
        self.dataResultsController.fetchedObjects.count, indexPath.section);
    if (self.dataResultsController.fetchedObjects.count - 1 == indexPath.section) {
        INVLogDebug(@"Will fetch next batch");

        [self fetchAnalysisTemplateFromCurrentOffset];
    }
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

#pragma mark - INVAnalysisTemplateOverviewTableViewCellDelegate
- (void)onCellSelected:(INVAnalysisTemplateOverviewTableViewCell *)selectedCell
{
    INVAnalysisTemplate *template = selectedCell.analysisTemplate;

    if (!self.selectedTemplates[template.analysisTemplateId]) {
        self.selectedTemplates[template.analysisTemplateId] = template;
    }
    self.saveButtonItem.enabled = self.selectedTemplates.count > 0;
}

- (void)onCellDeSelected:(INVAnalysisTemplateOverviewTableViewCell *)selectedCell
{
    INVAnalysisTemplate *template = selectedCell.analysisTemplate;

    if (self.selectedTemplates[template.analysisTemplateId]) {
        [self.selectedTemplates removeObjectForKey:template.analysisTemplateId];
    }
    self.saveButtonItem.enabled = self.selectedTemplates.count > 0;
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
            ^(INVAnalysisTemplateOverviewTableViewCell *cell, INVAnalysisTemplate *template, NSIndexPath *indexPath) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                cell.checked = self.selectedTemplates[template.analysisTemplateId] != nil;
                cell.analysisTemplate = template;

            };
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"AnalysisTemplateCell" configureBlock:cellConfigurationBlock];
    }
    return _dataSource;
}

- (INVPagingManager *)templatesPagingManager
{
    if (!_templatesPagingManager) {
        _templatesPagingManager =
            [[INVPagingManager alloc] initWithTotalCount:self.templateCount pageSize:DEFAULT_FETCH_PAGE_SIZE delegate:self];
    }
    return _templatesPagingManager;
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
        NSFetchRequest *fetchRequest = self.analysesManager.fetchRequestForAnalysisTemplates;
        _dataResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:self.analysesManager.managedObjectContext
                                                  sectionNameKeyPath:@"analysisTemplateId"
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowAnalysisTemplateDetailsSegue"]) {
        INVAnalysisTemplateOverviewTableViewCell *cell =
            [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        INVAnalysisTemplateDetailsTableViewController *analysisTemplateDetailsVC =
            (INVAnalysisTemplateDetailsTableViewController *) segue.destinationViewController;
        analysisTemplateDetailsVC.analysisTemplateId = cell.analysisTemplate.analysisTemplateId;
    }
}
@end
