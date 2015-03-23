//
//  INVRuleSetFilesTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVAnalysisManageFilesContainerViewController.h"
#import "INVAnalysisFilesListTableViewController.h"

@interface INVAnalysisManageFilesContainerViewController ()
@property (nonatomic, strong) INVAnalysisFilesListTableViewController *includedFilesTVC;
@property (nonatomic, strong) INVAnalysisFilesListTableViewController *excludedFilesTVC;
@end

#pragma mark - implementation
@implementation INVAnalysisManageFilesContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"MANAGE_FILES", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.includedFilesTVC = nil;
    self.excludedFilesTVC = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"IncludedFilesSegue"]) {
        self.includedFilesTVC = segue.destinationViewController;
        self.includedFilesTVC.projectId = self.projectId;
        self.includedFilesTVC.analysisId = self.analysisId;
        self.includedFilesTVC.showFilesForAnalysisId = YES;
    }
    else if ([segue.identifier isEqualToString:@"ExcludedFilesSegue"]) {
        self.excludedFilesTVC = segue.destinationViewController;
        self.excludedFilesTVC.projectId = self.projectId;
        self.excludedFilesTVC.analysisId = self.analysisId;
        self.excludedFilesTVC.showFilesForAnalysisId = NO;
    }
}

#pragma mark - UIEvent handlers
- (IBAction)onResetTapped:(UIBarButtonItem *)sender
{
    [self.includedFilesTVC resetFileEntries];
    [self.excludedFilesTVC resetFileEntries];
}
@end
