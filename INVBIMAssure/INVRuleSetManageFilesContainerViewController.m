//
//  INVRuleSetFilesTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/4/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleSetManageFilesContainerViewController.h"
#import "INVRuleSetFilesListTableViewController.h"

@interface INVRuleSetManageFilesContainerViewController ()
@property (nonatomic,strong)INVRuleSetFilesListTableViewController* includedFilesTVC;
@property (nonatomic,strong)INVRuleSetFilesListTableViewController* excludedFilesTVC;
@end

#pragma mark - implementation
@implementation INVRuleSetManageFilesContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"MANAGE_FILES", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.includedFilesTVC = nil;
    self.excludedFilesTVC = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"IncludedFilesSegue"]) {
        self.includedFilesTVC = segue.destinationViewController;
        self.includedFilesTVC .projectId = self.projectId;
        self.includedFilesTVC .ruleSetId = self.ruleSetId;
        self.includedFilesTVC .showFilesForRuleSetId = YES;
    }
    else if ([segue.identifier isEqualToString:@"ExcludedFilesSegue"]) {
        self.excludedFilesTVC = segue.destinationViewController;
        self.excludedFilesTVC.projectId = self.projectId;
        self.excludedFilesTVC.ruleSetId = self.ruleSetId;
        self.excludedFilesTVC.showFilesForRuleSetId = NO;
    }
}

#pragma mark - UIEvent handlers
- (IBAction)onResetTapped:(UIBarButtonItem *)sender {
    [self.includedFilesTVC resetFileEntries];
    [self.excludedFilesTVC resetFileEntries];
}
@end
