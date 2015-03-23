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
#import "INVAnalysisExecutionsTableViewController.h"
#import "UIView+INVCustomizations.h"

@interface INVAnalysisRunsCollectionViewController ()

@property NSMutableDictionary *analysisIdsToAnalyses;
@property NSMutableDictionary *analysesToAnalysisRuns;

@property NSMutableArray *validAnalysisRunsForCurrentPackage;
@property NSMutableDictionary *analysisRunsToRunResults;
- (IBAction)showAnalysisRunExecution:(UIButton *)sender;
@end

@implementation INVAnalysisRunsCollectionViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([INVAnalysisRunCollectionViewCell class]) bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"analysisRunCell"];

    [self fetchListOfAnalysisRuns];
}

#pragma mark - Content Management
- (void)fetchListOfAnalysisRuns
{
    self.validAnalysisRunsForCurrentPackage = [NSMutableArray new];

    [self.globalDataManager.invServerClient
        getAnalysisRunResultsForPkgVersion:self.packageVersionId
                       WithCompletionBlock:^(INVAnalysisRunDetailsArray analysisruns, INVEmpireMobileError *error) {
                           INV_ALWAYS:
                           INV_SUCCESS:
                               self.validAnalysisRunsForCurrentPackage = [analysisruns mutableCopy];
                               [self fetchListOfAnalyses];

                           INV_ERROR:
                               [self handleContentError:error];

                       }];
}

- (void)fetchListOfAnalyses
{
    self.analysisIdsToAnalyses = [[NSMutableDictionary alloc] initWithCapacity:0];

    id successBlock = [INVBlockUtils blockForExecutingBlock:^{
        [self.collectionView reloadData];
    } afterNumberOfCalls:self.validAnalysisRunsForCurrentPackage.count];

    for (INVAnalysisRunDetails *analysisDetails in self.validAnalysisRunsForCurrentPackage) {
        NSNumber *analysisId = analysisDetails.analysisId;

        [self.globalDataManager.invServerClient getAnalysesForId:analysisId
                                             withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                                 INV_ALWAYS:
                                                 INV_SUCCESS : {
                                                     self.analysisIdsToAnalyses[analysisId] = result;
                                                     [successBlock invoke];
                                                 }

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

    INVAnalysisRunDetails *details = self.validAnalysisRunsForCurrentPackage[indexPath.row];
    cell.result = details.runDetails;
    cell.analysis = self.analysisIdsToAnalyses[details.analysisId];

    return cell;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowAnalysisRunResultsSegue"]) {
        INVAnalysisRunCollectionViewCell *cell =
            [sender findSuperviewOfClass:[INVAnalysisRunCollectionViewCell class] predicate:nil];

        BOOL showError = YES;
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            INVAnalysisExecutionsTableViewController *vc =
            (INVAnalysisExecutionsTableViewController *) ((UINavigationController*)(segue.destinationViewController)).topViewController;
            vc.projectId = self.projectId;
            // TODO: THIS IS JUST FOR T1234ESTING. THIS WILL HAVE TO BE REPLACED WITH AN ANALYSIS RUNS VIEW THAT LISTS ALL ANALYSES
            if (cell.result && cell.result.count) {
                INVAnalysisRunResult* resultVal = cell.result[0];
                vc.analysisRunId = resultVal.analysisRunId;
                showError = NO;
            }
           
        }
        if (showError) {
            UIAlertController *errorController =
            [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSIS_RUN_RESULT_FETCH", nil)];
            
            [self presentViewController:errorController animated:YES completion:nil];

        }
    }
}

#pragma mark - UIEvent handlers
- (IBAction)showAnalysisRunExecution:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"ShowAnalysisRunResultsSegue" sender:sender];
}

@end
