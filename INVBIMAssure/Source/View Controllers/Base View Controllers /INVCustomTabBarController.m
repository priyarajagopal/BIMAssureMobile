//
//  INVCustomTabBarController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTabBarController.h"

@interface INVCustomTabBarController () <UITabBarControllerDelegate>
@property (nonatomic, readwrite) INVGlobalDataManager *globalDataManager;
@end

@implementation INVCustomTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.globalDataManager = [INVGlobalDataManager sharedInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.hud = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
