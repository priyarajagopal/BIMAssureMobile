//
//  INVAnalysisEditViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/17/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisEditViewController.h"
#import "UIView+INVCustomizations.h"

@interface INVAnalysisEditViewController () <UITextViewDelegate>

@property IBOutlet UITextField *analysisNameTextField;
@property IBOutlet UITextView *analysisDescriptionTextView;
@property IBOutlet UIBarButtonItem *saveButtonItem;

- (IBAction)onSaveSelected:(id)sender;
- (IBAction)onTextFieldTextChanged:(id)sender;

@end

@implementation INVAnalysisEditViewController

#pragma mark - Content Management

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.refreshControl = nil;

    [self updateUI];
}

- (void)setAnalysis:(INVAnalysis *)analysis
{
    _analysis = analysis;

    [self updateUI];
}

- (void)updateUI
{
    if (self.analysis) {
        self.navigationItem.title = NSLocalizedString(@"EDIT_ANALYSIS", nil);

        self.analysisNameTextField.text = self.analysis.name;
        self.analysisDescriptionTextView.text = self.analysis.overview;
        self.saveButtonItem.title = NSLocalizedString(@"SAVE", nil);
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"CREATE_ANALYSIS", nil);

        self.analysisNameTextField.text = nil;
        self.analysisDescriptionTextView.text = nil;
        self.saveButtonItem.title = NSLocalizedString(@"CREATE", nil);
    }
}

#pragma mark - IBActions

- (void)onSaveSelected:(id)sender
{
    if (self.analysis) {
        id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [self.globalDataManager.invServerClient updateAnalyses:self.analysis.analysisId
                                                      withName:self.analysisNameTextField.text
                                                andDescription:self.analysisDescriptionTextView.text
                                           withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                                               INV_ALWAYS:
                                                   [hud hide:YES];

                                               INV_SUCCESS:
                                                   [self performSegueWithIdentifier:@"unwind" sender:nil];

                                               INV_ERROR:
                                                   INVLogError(@"%@", error);

                                                   UIAlertController *errorController = [[UIAlertController alloc]
                                                       initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSIS_UPDATE", nil)];

                                                   [self presentViewController:errorController animated:YES completion:nil];
                                           }];
    }
    else {
        id hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [self.globalDataManager.invServerClient
            addAnalysesToProject:self.projectId
                        withName:self.analysisNameTextField.text
                  andDescription:self.analysisDescriptionTextView.text
             withCompletionBlock:^(id result, INVEmpireMobileError *error) {
                 INV_ALWAYS:
                     [hud hide:YES];

                 INV_SUCCESS:
                     [self performSegueWithIdentifier:@"unwind" sender:nil];

                 INV_ERROR:
                     INVLogError(@"%@", error);

                     UIAlertController *errorController =
                         [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_ANALYSIS_CREATE", nil)];

                     [self presentViewController:errorController animated:YES completion:nil];
             }];
    }
}

- (void)onTextFieldTextChanged:(id)sender
{
    if (self.analysis) {
        self.saveButtonItem.enabled =
            !([self.analysisNameTextField.text isEqualToString:self.analysis.name] &&
                [self.analysisDescriptionTextView.text isEqualToString:self.analysis.overview]) &&
            (self.analysisNameTextField.text.length > 0 && self.analysisDescriptionTextView.text.length > 0);
    }
    else {
        self.saveButtonItem.enabled =
            self.analysisNameTextField.text.length > 0 && self.analysisDescriptionTextView.text.length > 0;
    }
}

#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];

        CGSize size = [cell systemLayoutSizeFittingSize:CGSizeMake(tableView.bounds.size.width, 0)
                          withHorizontalFittingPriority:UILayoutPriorityRequired
                                verticalFittingPriority:UILayoutPriorityDefaultLow];

        [cell prepareForReuse];

        return size.height;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self onTextFieldTextChanged:textView];

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
