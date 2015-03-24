//
//  INVAnalysisRuleElementTypes.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/24/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisRuleElementTypesTableViewController.h"
#import "INVBlockUtils.h"

@interface INVAnalysisRuleElementTypesTableViewController ()

@property NSArray *packageMasters;
@property NSMutableDictionary *packageElementCategories;

@end

@implementation INVAnalysisRuleElementTypesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self fetchListOfPackageMasters];
}

#pragma mark - Content Management

- (void)fetchListOfPackageMasters
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.globalDataManager.invServerClient
        getPkgMembershipForAnalysis:self.analysisId
                WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                    INV_ALWAYS:
                    INV_SUCCESS : {
                        NSSet *packageMasterIds =
                            [self.globalDataManager.invServerClient.analysesManager pkgMastersForAnalysisId:self.analysisId];

                        [self fetchPackageMastersForIds:packageMasterIds];
                    }

                    INV_ERROR:
                        INVLogError(@"%@", error);
                }];
}

- (void)fetchPackageMastersForIds:(NSSet *)ids
{
    [self.globalDataManager.invServerClient
        getAllPkgMastersForProject:self.projectId
               WithCompletionBlock:^(INVEmpireMobileError *error) {
                   INV_ALWAYS:
                   INV_SUCCESS:
                       self.packageMasters =
                           [self.globalDataManager.invServerClient.projectManager packageFilesForMasterIds:[ids allObjects]];
                       [self fetchListOfCategories];

                   INV_ERROR:
                       INVLogError(@"%@", error);

               }];
}

- (void)fetchListOfCategories
{
    self.packageElementCategories = [NSMutableDictionary new];

    id alwaysBlock = [INVBlockUtils blockForExecutingBlock:^{
        [self.hud hide:YES];
        [self.refreshControl endRefreshing];
    } afterNumberOfCalls:self.packageMasters.count];

    id successBlock = [INVBlockUtils blockForExecutingBlock:^{
        [self.tableView reloadData];
    } afterNumberOfCalls:self.packageMasters.count];

    id errorBlock = [INVBlockUtils blockForExecutingBlock:^{
        UIAlertController *errorController =
            [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_ELEMENT_TYPES_LOAD", nil)];
        [self presentViewController:errorController animated:YES completion:nil];
    } afterNumberOfCalls:1];

    for (INVPackage *package in self.packageMasters) {
        [self.globalDataManager.invServerClient
            fetchBuildingElementCategoriesForPackageVersionId:package.tipId
                                          withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                              INV_ALWAYS:
                                                  [alwaysBlock invoke];

                                              INV_SUCCESS:
                                                  self.packageElementCategories[package] =
                                                      [result valueForKeyPath:@"aggregations.category.buckets.key"];

                                                  [successBlock invoke];

                                              INV_ERROR:
                                                  INVLogError(@"%@", error);

                                                  [errorBlock invoke];
                                          }];
    }
}

#pragma mark - IBActions

- (void)onRefreshControlSelected:(id)sender
{
    [self fetchListOfPackageMasters];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.packageMasters.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.packageElementCategories[self.packageMasters[section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.packageMasters[section] packageName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ruleElementType"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ruleElementType"];
    }

    INVPackage *packageMaster = self.packageMasters[indexPath.section];

    cell.textLabel.text = self.packageElementCategories[packageMaster][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;

    if ([cell.textLabel.text isEqualToString:self.currentSelection]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INVPackage *packageMaster = self.packageMasters[indexPath.section];
    self.currentSelection = self.packageElementCategories[packageMaster][indexPath.row];

    [self.tableView reloadData];
}

@end
