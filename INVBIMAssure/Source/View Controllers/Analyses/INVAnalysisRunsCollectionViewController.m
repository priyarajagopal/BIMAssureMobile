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

@property (readonly) NSArray *sortedAnalyses;

@property NSMutableDictionary *analysisIdsToAnalyses;
@property NSMutableArray *validAnalysisRunsForCurrentPackage;

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
                       WithCompletionBlock:^(INVAnalysisRunArray analysisruns, INVEmpireMobileError *error) {
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
    [self.globalDataManager.invServerClient
        getAllAnalysisForPkgMaster:self.packageMasterId
                         inProject:self.projectId
               withCompletionBlock:^(INVEmpireMobileError *error) {
                   INV_ALWAYS:
                   INV_SUCCESS : {
                       NSArray *analyses =
                           [self.globalDataManager.invServerClient.analysesManager analysesForPkgMaster:self.packageMasterId];

                       self.analysisIdsToAnalyses =
                           [NSMutableDictionary dictionaryWithObjects:analyses
                                                              forKeys:[analyses valueForKeyPath:@"analysisId"]];

                       [self.collectionView reloadData];
                   }

                   INV_ERROR:
                       [self handleContentError:error];
               }];
}

- (NSArray *)sortedAnalyses
{
    return [[self.analysisIdsToAnalyses allValues]
        sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ]];
}

- (INVAnalysisRun *)latestRunForAnalysis:(INVAnalysis *)analysis
{
    return [[[self.validAnalysisRunsForCurrentPackage
        filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"analysisId = %@", analysis.analysisId]]
        sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES] ]] firstObject];
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
    return self.analysisIdsToAnalyses.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    INVAnalysisRunCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"analysisRunCell" forIndexPath:indexPath];

    INVAnalysis *analysis = self.sortedAnalyses[indexPath.row];

    cell.analysis = analysis;
    cell.result = [self latestRunForAnalysis:analysis];

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
                (INVAnalysisExecutionsTableViewController *) ((UINavigationController *) (segue.destinationViewController))
                    .topViewController;
            vc.projectId = self.projectId;

            if (cell.result) {
                INVAnalysisRun *resultVal = cell.result;
                vc.analysisRunId = resultVal.analysisRunId;
                vc.fileVersionId = self.packageVersionId;
                vc.fileMasterId = self.packageMasterId;
                vc.projectId = self.projectId;
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
