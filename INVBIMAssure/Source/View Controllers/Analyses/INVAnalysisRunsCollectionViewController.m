//
//  INVAnalysisRunsCollectionViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/20/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisRunsCollectionViewController.h"
#import "INVAnalysisRunCollectionViewCell.h"
#import "NSArray+INVCustomizations.h"
#import "INVBlockUtils.h"

#import <EmpireMobileManager/INVAnalysisRun.h>

@interface INVAnalysisRunsCollectionViewController ()

@property NSMutableDictionary *analysisIdsToAnalyses;
@property NSMutableDictionary *analysesToAnalysisRuns;

@property NSMutableArray *validAnalysisRunsForCurrentPackage;
@property NSMutableDictionary *analysisRunsToRunResults;

@end

@implementation INVAnalysisRunsCollectionViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([INVAnalysisRunCollectionViewCell class]) bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"analysisRunCell"];

    [self fetchAnalysisMembership];
}

#pragma mark - Content Management

- (void)fetchAnalysisMembership
{
    [self.globalDataManager.invServerClient
        getAnalysisMembershipForPkgMaster:self.packageMasterId
                      WithCompletionBlock:^(id result, INVEmpireMobileError *error) {
                          INV_ALWAYS:
                          INV_SUCCESS:
                              self.analysisIdsToAnalyses = [[NSMutableDictionary alloc]
                                  initWithObjects:[NSArray arrayWithObject:[NSNull null] repeated:[result count]]
                                          forKeys:[result valueForKeyPath:@"analysisId"]];

                              [self fetchListOfAnalyses];

                          INV_ERROR:
                              [self handleContentError:error];
                      }];
}

- (void)fetchListOfAnalyses
{
    [self.globalDataManager.invServerClient getAllAnalysesForProject:self.projectId
                                                 withCompletionBlock:^(INVEmpireMobileError *error) {
                                                     INV_ALWAYS:
                                                     INV_SUCCESS : {
                                                         NSArray *analyses =
                                                             [self.globalDataManager.invServerClient.analysesManager
                                                                 analysesForIds:[self.analysisIdsToAnalyses allKeys]];
                                                         for (INVAnalysis *analysis in analyses) {
                                                             self.analysisIdsToAnalyses[analysis.analysisId] = analysis;
                                                         }

                                                         [self fetchListOfAnalysisRuns];
                                                     }

                                                     INV_ERROR:
                                                         [self handleContentError:error];
                                                 }];
}

- (void)fetchListOfAnalysisRuns
{
    self.analysesToAnalysisRuns = [NSMutableDictionary new];

    id successBlock = [INVBlockUtils blockForExecutingBlock:^{
        [self filterAnalysisRuns];
    } afterNumberOfCalls:self.analysisIdsToAnalyses.count];

    for (INVAnalysis *analysis in [self.analysisIdsToAnalyses allValues]) {
        [self.globalDataManager.invServerClient getAnalysisRunsForAnalysis:analysis.analysisId
                                                       WithCompletionBlock:^(NSArray *result, INVEmpireMobileError *error) {
                                                           INV_ALWAYS:
                                                           INV_SUCCESS:
                                                               self.analysesToAnalysisRuns[analysis] = result;
                                                               [successBlock invoke];

                                                           INV_ERROR:
                                                               [self handleContentError:error];
                                                       }];
    }
}

- (void)filterAnalysisRuns
{
    self.validAnalysisRunsForCurrentPackage = [NSMutableArray new];

    // This flattens out the array of analysis runs
    [[self.analysesToAnalysisRuns allValues]
        makeObjectsPerformSelector:@selector(enumerateObjectsUsingBlock:)
                        withObject:^(INVAnalysisRun *object, NSUInteger index, BOOL *stop) {
                            if ([object.pkgVersionId isEqual:self.packageVersionId]) {
                                [self.validAnalysisRunsForCurrentPackage addObject:object];
                            }
                        }];

    [self fetchListOfAnalysisRunResults];
}

- (void)fetchListOfAnalysisRunResults
{
    self.analysisRunsToRunResults = [NSMutableDictionary new];

    id successBlock = [INVBlockUtils blockForExecutingBlock:^{
        [self.collectionView reloadData];
    } afterNumberOfCalls:self.validAnalysisRunsForCurrentPackage.count];

    for (INVAnalysisRun *run in self.validAnalysisRunsForCurrentPackage) {
        [self.globalDataManager.invServerClient
            getExecutionResultsForAnalysisRun:run.analysisRunId
                          WithCompletionBlock:^(INVAnalysisRunResultsArray response, INVEmpireMobileError *error) {
                              INV_ALWAYS:
                              INV_SUCCESS:
                                  self.analysisRunsToRunResults[run] = response;
                                  [successBlock invoke];

                              INV_ERROR:
                                  [self handleContentError:error];
                          }];
    }
}

#pragma mark - Error Handling

- (void)handleContentError:(INVEmpireMobileError *)error
{
    INVLogError(@"%@", error);

    UIAlertController *errorController =
        [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSIS_RUN_FETCH", nil)];

    [self presentViewController:errorController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSouce

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.validAnalysisRunsForCurrentPackage.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    INVAnalysisRunCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"analysisRunCell" forIndexPath:indexPath];

    cell.run = self.validAnalysisRunsForCurrentPackage[indexPath.row];

    cell.analysis = self.analysisIdsToAnalyses[cell.run.analysisId];
    cell.runResults = self.analysisRunsToRunResults[cell.run];

    return cell;
}

@end
