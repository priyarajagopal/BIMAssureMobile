//
//  INVProjectEditViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVProjectEditViewController.h"
#import "INVMutableArrayTableViewDataSource.h"
#import "INVStockThumbnailCollectionViewController.h"
#import "UIImage+INVCustomizations.h"

#import <MBProgressHUD/MBProgressHUD.h>

#define SHOW_PROJECT_MEMBERS 0

@interface INVProjectEditViewControllerMembersTableViewDelegate : NSObject<UITableViewDelegate>

@property IBOutlet UITableView *membersInAccountTableView;
@property IBOutlet UITableView *membersInProjectTableView;

@property IBOutlet INVMutableArrayTableViewDataSource *membersInAccountDataSource;
@property IBOutlet INVMutableArrayTableViewDataSource *membersInProjectDataSource;

@end

@implementation INVProjectEditViewControllerMembersTableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.membersInAccountTableView || tableView == self.membersInProjectTableView) {
        UITableView *sourceTableView = tableView;
        UITableView *destinationTableView =
            (sourceTableView == self.membersInAccountTableView ? self.membersInProjectTableView
                                                               : self.membersInAccountTableView);

        INVMutableArrayTableViewDataSource *sourceDataSource =
            (INVMutableArrayTableViewDataSource *) sourceTableView.dataSource;
        INVMutableArrayTableViewDataSource *destinationDataSource =
            (INVMutableArrayTableViewDataSource *) destinationTableView.dataSource;

        NSString *memberName = sourceDataSource[indexPath.row];

        [sourceTableView beginUpdates];
        [sourceDataSource removeObjectAtIndex:indexPath.row];

        [sourceTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [sourceTableView endUpdates];

        [destinationTableView beginUpdates];
        [destinationDataSource addObject:memberName];

        [destinationTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                            withRowAnimation:UITableViewRowAnimationAutomatic];
        [destinationTableView endUpdates];
    }
}

@end

@interface INVProjectEditViewController () <UINavigationControllerDelegate, UITextFieldDelegate>

@property IBOutlet UITextField *projectNameTextField;
@property IBOutlet UITextField *projectDescriptionTextField;
@property IBOutlet UITextField *addNewMemberTextField;
@property IBOutlet UITextField *invitationMessageTextField;
@property IBOutlet UIButton *currentThumbnailButton;
@property IBOutlet UIBarButtonItem *saveBarButtonItem;

@property IBOutlet UITableView *membersInAccountTableView;
@property IBOutlet UITableView *membersInProjectTableView;

@property IBOutlet INVMutableArrayTableViewDataSource *membersInAccountDataSource;
@property IBOutlet INVMutableArrayTableViewDataSource *membersInProjectDataSource;

@property (nonatomic, assign) BOOL projectImageUpdated;

- (IBAction)save:(id)sender;
- (IBAction)textFieldTextChanged:(id)sender;
- (IBAction)selectThumbnail:(id)sender;

@end

@implementation INVProjectEditViewController

#pragma mark - View Lifecycle

- (void)updateUI
{
    if (self.currentProject) {
        self.navigationItem.title =
            [NSString stringWithFormat:NSLocalizedString(@"EDIT_PROJECT", nil), self.currentProject.name];

        self.projectNameTextField.text = self.currentProject.name;
        self.projectDescriptionTextField.text = self.currentProject.overview;

        self.saveBarButtonItem.enabled = NO;

        [self.currentThumbnailButton setImage:[UIImage imageNamed:@"ImageNotFound"] forState:UIControlStateNormal];

        [self.globalDataManager.invServerClient
            getThumbnailImageForProject:self.currentProject.projectId
                  withCompletionHandler:^(id result, INVEmpireMobileError *error) {
                      if (error) {
                          INVLogError(@"%@", error);
                          [self.currentThumbnailButton setImage:[UIImage imageNamed:@"ImageNotFound"]
                                                       forState:UIControlStateNormal];

                          return;
                      }

                      [self.currentThumbnailButton setImage:[UIImage imageWithData:result] forState:UIControlStateNormal];
                  }];
    }
    else {
        self.navigationItem.title = NSLocalizedString(@"CREATE_PROJECT", nil);
        self.projectNameTextField.text = nil;
        self.projectDescriptionTextField.text = nil;

        self.saveBarButtonItem.enabled = NO;

        [self.currentThumbnailButton setImage:[UIImage imageNamed:@"project_thumbnail_0"] forState:UIControlStateNormal];
    }

    [self.globalDataManager.invServerClient getMembershipForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        NSArray *members = [self.globalDataManager.invServerClient.accountManager accountMembership];

        [self.membersInAccountDataSource addObjectsFromArray:[members valueForKey:@"email"]];
        [self.membersInAccountTableView reloadData];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"unwind"]) {
        
        if (sender == self) {
            // Save
            if ([self.delegate respondsToSelector:@selector(onProjectEditSaved:)]) {
                [self.delegate onProjectEditSaved:self];
            }
        }
        else
        
        {
            // Cancel
            if ([self.delegate respondsToSelector:@selector(onProjectEditCancelled:)]) {
                [self.delegate onProjectEditCancelled:self];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.refreshControl = nil;
    self.currentThumbnailButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

    self.membersInAccountDataSource.tableViewCellIdentifier = @"memberCell";
    self.membersInProjectDataSource.tableViewCellIdentifier = @"memberCell";

    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentProject:(INVProject *)currentProject
{
    _currentProject = currentProject;

    [self updateUI];
}

#pragma mark - UITableViewDataSource

#if !SHOW_PROJECT_MEMBERS

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

#endif

#pragma mark - IBActions

- (IBAction)save:(id)sender
{
    // Force the first responder to resign
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:self forEvent:nil];

    [self showLoadProgress];
    NSString *projectName = self.projectNameTextField.text;
    NSString *projectDescription = self.projectDescriptionTextField.text;

    projectName = [projectName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    projectDescription = [projectDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    projectDescription = projectDescription && projectDescription.length?projectDescription:nil;
   

    if (self.currentProject) {
        [self.globalDataManager.invServerClient updateProjectWithId:self.currentProject.projectId
                                                           withName:projectName
                                                     andDescription:projectDescription
                              ForSignedInAccountWithCompletionBlock:INV_COMPLETION_HANDLER {
                                  INV_ALWAYS:
                                  [self.hud hide:YES];

                                  INV_SUCCESS:
                                      if (self.projectImageUpdated) {
                                          [self uploadProjectThumbnailForProject:self.currentProject.projectId];
                                      }
                                      else {
                                          [self showProjectAlert:NSLocalizedString(@"PROJECT_UPDATED", nil)];
                                      }

                                  INV_ERROR:
                                      INVLogError(@"%@", error);

                                      [self showProjectAlert:NSLocalizedString(@"ERROR_PROJECT_UPDATE", nil)];
                              }];
    }
    else {
        [self.globalDataManager.invServerClient createProjectWithName:projectName
                                                       andDescription:projectDescription
                                ForSignedInAccountWithCompletionBlock:^(INVProject *project, INVEmpireMobileError *error) {
                                    // NOTE: We *probably* need more info about the created project here.
                                    [self.hud hide:YES];

                                    if (error) {
                                        [self showProjectAlert:NSLocalizedString(@"ERROR_PROJECT_CREATE", nil)];
                                    }
                                    else {
                                        [self uploadProjectThumbnailForProject:project.projectId];
                                    }
                                }];
    }
}

- (void)textFieldTextChanged:(id)sender
{
    self.saveBarButtonItem.enabled = ([self.projectNameTextField text].length > 0);
}

- (void)selectThumbnail:(id)sender
{
    UIAlertController *alertController = [[UIAlertController alloc]
        initForImageSelectionInFolder:@"Project Thumbnails"
                          withHandler:^(UIImage *image) {
                              [self.currentThumbnailButton setImage:image forState:UIControlStateNormal];
                              self.projectImageUpdated = YES;

                              [self textFieldTextChanged:nil];
                          }];

    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect =
        [self.currentThumbnailButton convertRect:self.currentThumbnailButton.bounds toView:self.view];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField != self.addNewMemberTextField) {
        return YES;
    }

    // TODO: Use address book?
    NSString *searchText =
        [self.addNewMemberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL isEmail = [searchText isValidEmail];

    if (!isEmail) {
        self.navigationItem.prompt = NSLocalizedString(@"INVALID_EMAIL", nil);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.navigationItem.prompt = nil;
        });
    }
    else {
        self.addNewMemberTextField.text = nil;
        [self.addNewMemberTextField resignFirstResponder];

        [self.membersInProjectTableView beginUpdates];

        [self.membersInProjectDataSource addObject:searchText];
        [self.membersInProjectTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];

        [self.membersInProjectTableView endUpdates];
    }

    return NO;
}

#pragma mark - Helpers

- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
    [self.hud show:YES];
    [self.view addSubview:self.hud];
}



- (void)showProjectAlert:(NSString *)title
{
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self performSegueWithIdentifier:@"unwind" sender:self];
                                                      }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)uploadProjectThumbnailForProject:(NSNumber *)projectId
{
    NSURL *fileURL = [self.currentThumbnailButton.imageView.image writeImageToTemporaryFile];

    [self.globalDataManager.invServerClient
        addThumbnailImageForProject:projectId
                          thumbnail:fileURL
              withCompletionHandler:^(INVEmpireMobileError *error) {
                  if (error) {
                      INVLogError(@"%@", error);
                      [self showProjectAlert:NSLocalizedString(@"PROJECT_CREATED_NO_THUMBNAIL", nil)];
                  }
                  else {
                      [self.globalDataManager addToRecentlyEditedProjectList:projectId];
                      NSString *mesgToDisplay = NSLocalizedString(@"PROJECT_CREATED", nil);
                      if (self.currentProject) {
                          mesgToDisplay = NSLocalizedString(@"PROJECT_UPDATED", nil);
                      }
                      [self showProjectAlert:mesgToDisplay];
                  }
              }];
}

@end
