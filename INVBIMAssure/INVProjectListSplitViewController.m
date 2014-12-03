 //
//  INVProjectListSplitViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectListSplitViewController.h"
#import "INVProjectsTableViewController.h"

@interface INVProjectListSplitViewController ()<UISplitViewControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation INVProjectListSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.preferredDisplayMode =  UISplitViewControllerDisplayModeAllVisible;
    self.splitViewPanGestureRecognizer.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}



#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0) {
    if ([self.splitViewPanGestureRecognizer isEqual:gestureRecognizer] ) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
