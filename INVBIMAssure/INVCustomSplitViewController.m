//
//  INVCustomSplitViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomSplitViewController.h"


@interface INVCustomSplitViewController ()<UISplitViewControllerDelegate>
@property (nonatomic,readwrite)INVGlobalDataManager* globalDataManager;

@end

@implementation INVCustomSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.globalDataManager = [INVGlobalDataManager sharedInstance];
    self.hud = [[MBProgressHUD alloc]init];
    
    [self.hud setAnimationType:MBProgressHUDAnimationFade];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
