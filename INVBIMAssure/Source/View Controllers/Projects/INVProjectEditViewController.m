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

#import <MBProgressHUD/MBProgressHUD.h>

#define SHOW_PROJECT_MEMBERS 0

@interface INVProjectEditViewControllerMembersTableViewDelegate : NSObject<UITableViewDelegate>

@property IBOutlet UITableView *membersInAccountTableView;
@property IBOutlet UITableView *membersInProjectTableView;

@property IBOutlet INVMutableArrayTableViewDataSource *membersInAccountDataSource;
@property IBOutlet INVMutableArrayTableViewDataSource *membersInProjectDataSource;

@end

@implementation INVProjectEditViewControllerMembersTableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.membersInAccountTableView || tableView == self.membersInProjectTableView) {
        UITableView *sourceTableView = tableView;
        UITableView *destinationTableView = (sourceTableView == self.membersInAccountTableView ? self.membersInProjectTableView : self.membersInAccountTableView);
        
        INVMutableArrayTableViewDataSource *sourceDataSource = (INVMutableArrayTableViewDataSource *) sourceTableView.dataSource;
        INVMutableArrayTableViewDataSource *destinationDataSource =  (INVMutableArrayTableViewDataSource *) destinationTableView.dataSource;
        
        NSString *memberName = sourceDataSource[indexPath.row];
        
        [sourceTableView beginUpdates];
        [sourceDataSource removeObjectAtIndex:indexPath.row];
        
        [sourceTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [sourceTableView endUpdates];
        
        [destinationTableView beginUpdates];
        [destinationDataSource addObject:memberName];
        
        [destinationTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [destinationTableView endUpdates];
    }
}

@end

@interface INVProjectEditViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, INVStockThumbnailCollectionViewControllerDelegate>

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

-(IBAction) save:(id)sender;
-(IBAction) projectNameChanged:(id)sender;
-(IBAction) selectThumbnail:(id)sender;

@end

@implementation INVProjectEditViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.refreshControl = nil;
    self.currentThumbnailButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.membersInAccountDataSource.tableViewCellIdentifier = @"memberCell";
    self.membersInProjectDataSource.tableViewCellIdentifier = @"memberCell";
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setCurrentProject:(INVProject *)currentProject {
    _currentProject = currentProject;
    
    [self updateUI];
}

#pragma mark - UITableViewDataSource

#if !SHOW_PROJECT_MEMBERS

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#endif

-(void) updateUI {
    if (self.currentProject) {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"EDIT_PROJECT", nil), self.currentProject.name];

        self.projectNameTextField.text = self.currentProject.name;
        
        // NOTE: No description in model for projects currently. JIRA Bug EMOB-98.
        // self.projectDescriptionTextField.text = self.currentProject.description;
    } else {
        self.navigationItem.title = NSLocalizedString(@"CREATE_PROJECT", nil);
        self.projectNameTextField.text = nil;
        self.projectDescriptionTextField.text = nil;
    }
    
    [self.globalDataManager.invServerClient getMembershipForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        NSArray *members = [self.globalDataManager.invServerClient.accountManager accountMembership];
        
        [self.membersInAccountDataSource addObjectsFromArray:[members valueForKey:@"email"]];
        [self.membersInAccountTableView reloadData];
    }];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"unwind"]) {
        if (sender == self) {
            // Save
            if ([self.delegate respondsToSelector:@selector(onProjectEditSaved:)]) {
                [self.delegate onProjectEditSaved:self];
            }
        } else {
            // Cancel
            if ([self.delegate respondsToSelector:@selector(onProjectEditCancelled:)] ) {
                [self.delegate onProjectEditCancelled:self];
            }
        }
    }
}

-(void) showProjectAlert:(NSString *) title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:title
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self performSegueWithIdentifier:@"unwind" sender:self];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) save:(id)sender {
    NSString *projectName = self.projectNameTextField.text;
    NSString *projectDescription = self.projectDescriptionTextField.text;
    
    projectName = [projectName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    projectDescription = [projectDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.currentProject) {
        [self.globalDataManager.invServerClient updateProjectWithId:self.currentProject.projectId
                                                                            withName:projectName
                                                                      andDescription:projectDescription
                                               ForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
                                                   // TODO: Error handling
                                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                   
                                                   [self showProjectAlert:NSLocalizedString(@"PROJECT_UPDATED", nil)];
                                               }];
    } else {
        [self.globalDataManager.invServerClient createProjectWithName:projectName
                                                                        andDescription:projectDescription
                                                 ForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
                                                     // NOTE: We *probably* need more info about the created project here.
                                                     // TODO: Error handling
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                     
                                                     [self showProjectAlert:NSLocalizedString(@"PROJECT_CREATED", nil)];
                                                 }];
    }
}

-(void) projectNameChanged:(id)sender {
    self.saveBarButtonItem.enabled = ([sender text].length > 0);
}

-(void) selectThumbnail:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"STOCK_IMAGES", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        INVStockThumbnailCollectionViewController *stockThumbnailController = [[INVStockThumbnailCollectionViewController alloc] init];
        stockThumbnailController.delegate = self;
        
        stockThumbnailController.modalPresentationStyle = UIModalPresentationPopover;
        stockThumbnailController.preferredContentSize = CGSizeMake(320, 320);
        
        stockThumbnailController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        stockThumbnailController.popoverPresentationController.sourceView = self.view;
        stockThumbnailController.popoverPresentationController.sourceRect = [self.currentThumbnailButton convertRect:self.currentThumbnailButton.bounds toView:self.view];;
        
        [self presentViewController:stockThumbnailController animated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"PHOTO_LIBRARY", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
        imagePickerController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        imagePickerController.popoverPresentationController.sourceView = self.view;
        imagePickerController.popoverPresentationController.sourceRect = [self.currentThumbnailButton convertRect:self.currentThumbnailButton.bounds toView:self.view];;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }]];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"TAKE_PHOTO", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = [self.currentThumbnailButton convertRect:self.currentThumbnailButton.bounds toView:self.view];;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.currentThumbnailButton setImage:info[UIImagePickerControllerOriginalImage] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) stockThumbnailCollectionViewController:(INVStockThumbnailCollectionViewController *)controller didSelectStockThumbnail:(UIImage *)image {
    [self.currentThumbnailButton setImage:image forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField != self.addNewMemberTextField) {
        return YES;
    }
     
    // TODO: Use address book?
    NSString *searchText = [self.addNewMemberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL isEmail = [searchText isValidEmail];
    
    if (!isEmail) {
        self.navigationItem.prompt = NSLocalizedString(@"INVALID_EMAIL", nil);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.navigationItem.prompt = nil;
        });
    } else {
        self.addNewMemberTextField.text = nil;
        [self.addNewMemberTextField resignFirstResponder];
        
        [self.membersInProjectTableView beginUpdates];
        
        [self.membersInProjectDataSource addObject:searchText];
        [self.membersInProjectTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.membersInProjectTableView endUpdates];
    }
    
    return NO;
}

@end
