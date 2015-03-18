//
//  INVFileManageRuleSetsContainerViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVFileManageRuleSetsContainerViewController.h"
#import "INVFileAnalysesMembershipTableViewController.h"

@interface INVFileManageRuleSetsContainerViewController ()
@property (nonatomic, strong) INVFileAnalysesMembershipTableViewController *includedRuleSetsTVC;
@property (nonatomic, strong) INVFileAnalysesMembershipTableViewController *excludedRuleSetsTVC;
@end

#pragma mark - implementation
@implementation INVFileManageRuleSetsContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"MANAGE_RULESETS", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.includedRuleSetsTVC = nil;
    self.excludedRuleSetsTVC = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"IncludedRuleSetsSegue"]) {
        self.includedRuleSetsTVC = segue.destinationViewController;
        self.includedRuleSetsTVC.projectId = self.projectId;
        self.includedRuleSetsTVC.fileId = self.fileId;
        self.includedRuleSetsTVC.showAnalysesForPkg = YES;
    }
    else if ([segue.identifier isEqualToString:@"ExcludedRuleSetsSegue"]) {
        self.excludedRuleSetsTVC = segue.destinationViewController;
        self.excludedRuleSetsTVC.projectId = self.projectId;
        self.excludedRuleSetsTVC.fileId = self.fileId;
        self.excludedRuleSetsTVC.showAnalysesForPkg = NO;
    }
}

#pragma mark - UIEvent handlers
- (IBAction)onResetTapped:(UIBarButtonItem *)sender
{
    [self.includedRuleSetsTVC resetAnalysesEntries];
    [self.excludedRuleSetsTVC resetAnalysesEntries];
}
@end