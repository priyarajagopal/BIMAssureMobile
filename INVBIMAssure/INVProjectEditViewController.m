//
//  INVProjectEditViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVProjectEditViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

@interface INVProjectEditViewController ()

@property IBOutlet UITextField *projectNameTextField;
@property IBOutlet UITextField *projectDescriptionTextField;

-(IBAction) save:(id)sender;

@end

@implementation INVProjectEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

@end
