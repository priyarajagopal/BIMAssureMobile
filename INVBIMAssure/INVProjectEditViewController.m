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

@interface INVProjectEditViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, INVStockThumbnailCollectionViewControllerDelegate>

@property IBOutlet UITextField *projectNameTextField;
@property IBOutlet UITextField *projectDescriptionTextField;
@property IBOutlet UITextField *addNewMemberTextField;
@property IBOutlet UITextField *invitationMessageTextField;
@property IBOutlet UIButton *currentThumbnailButton;

@property IBOutlet UITableView *membersInAccountTableView;
@property IBOutlet UITableView *membersInProjectTableView;

// This is an IBOutlet, as it hooks into an INVMutableArrayTableViewDataSource object.
@property IBOutlet INVMutableArrayTableViewDataSource *membersInAccountDataSource;
@property IBOutlet INVMutableArrayTableViewDataSource *membersInProjectDataSource;

-(IBAction) save:(id)sender;
-(IBAction) selectThumbnail:(id)sender;

@end

@implementation INVProjectEditViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.currentThumbnailButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
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
    
}

-(void) save:(id)sender {
    NSString *projectName = self.projectNameTextField.text;
    NSString *projectDescription = self.projectDescriptionTextField.text;
    
    projectName = [projectName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    projectDescription = [projectDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (projectName.length == 0) {
        self.navigationItem.prompt = @"Invalid Project Name";
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.navigationItem.prompt = nil;
        });
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.currentProject) {
        [[[INVGlobalDataManager sharedInstance] invServerClient] updateProjectWithId:self.currentProject.projectId
                                                                            withName:projectName
                                                                      andDescription:projectDescription
                                               ForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
                                                   // TODO: Error handling
                                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                   
                                                   [self performSegueWithIdentifier:@"unwind" sender:self];
                                               }];
    } else {
        [[[INVGlobalDataManager sharedInstance] invServerClient] createProjectWithName:projectName
                                                                        andDescription:projectDescription
                                                 ForSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
                                                     // NOTE: We *probably* need more info about the created project here.
                                                     // TODO: Error handling
                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                     
                                                     [self performSegueWithIdentifier:@"unwind" sender:self];    
                                                 }];
    }
}

-(void) selectThumbnail:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Stock Images" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // TODO: Stock images.
        INVStockThumbnailCollectionViewController *stockThumbnailController = [[INVStockThumbnailCollectionViewController alloc] init];
        stockThumbnailController.delegate = self;
        
        stockThumbnailController.modalPresentationStyle = UIModalPresentationPopover;
        stockThumbnailController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        stockThumbnailController.popoverPresentationController.sourceView = self.view;
        stockThumbnailController.popoverPresentationController.sourceRect = [self.currentThumbnailButton convertRect:self.currentThumbnailButton.bounds toView:self.view];;
        
        [self presentViewController:stockThumbnailController animated:YES completion:nil];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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
        [alertController addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Remove Image" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.currentThumbnailButton setImage:[UIImage imageNamed:@"ImageNotFound"] forState:UIControlStateNormal];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        return;
    }
    
    if (tableView == self.membersInAccountTableView || tableView == self.membersInProjectTableView) {
        UITableView *sourceTableView = tableView;
        UITableView *destinationTableView = (sourceTableView == self.membersInAccountTableView ? self.membersInProjectTableView : self.membersInAccountTableView);
        
        INVMutableArrayTableViewDataSource *sourceDataSource = (INVMutableArrayTableViewDataSource *) sourceTableView.dataSource;
        INVMutableArrayTableViewDataSource *destinationDataSource =  (INVMutableArrayTableViewDataSource *) destinationTableView.dataSource;
        
        NSString *memberName = sourceDataSource[indexPath.row];
        
        [sourceDataSource removeObjectAtIndex:indexPath.row];
        [destinationDataSource addObject:memberName];
        
        [sourceTableView reloadData];
        [destinationTableView reloadData];
        
        NSLog(@"Source: %@", sourceDataSource);
        NSLog(@"Destination: %@", destinationDataSource);
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField != self.addNewMemberTextField) {
        return YES;
    }
    
    NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    
    // TODO: Use address book?
    NSString *searchText = [self.addNewMemberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    __block BOOL isEmail = NO;
    
    [dataDetector enumerateMatchesInString:searchText
                                   options:0
                                     range:NSMakeRange(0, searchText.length)
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                    if (result.range.length == searchText.length &&
                                        result.resultType == NSTextCheckingTypeLink &&
                                        [result.URL.scheme isEqualToString:@"mailto"]) {
                                        isEmail = YES;
                                    }
                                }];
    
    if (!isEmail) {
        self.navigationItem.prompt = @"Invalid Email";
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.navigationItem.prompt = nil;
        });
    } else {
        self.addNewMemberTextField.text = nil;
        [self.addNewMemberTextField resignFirstResponder];
        
        [self.membersInProjectDataSource addObject:searchText];
        [self.membersInProjectTableView reloadData];
    }
    
    return NO;
}

@end
