//
//  INVProjectDetailsTabViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectDetailsTabViewController.h"
#import "INVProjectFilesListViewController.h"

@interface INVProjectDetailsTabViewController ()

@end

@implementation INVProjectDetailsTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setSelectedProject:(INVProject *)project
{
    [self.viewControllers makeObjectsPerformSelector:@selector(setProjectId:) withObject:project.projectId];
}

#pragma mark - UITabbarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}

@end
