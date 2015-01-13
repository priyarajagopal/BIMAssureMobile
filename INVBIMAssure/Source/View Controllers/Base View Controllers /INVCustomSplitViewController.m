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
@property (nonatomic, readwrite)UIPanGestureRecognizer* splitViewPanGestureRecognizer;

@end

@implementation INVCustomSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.globalDataManager = [INVGlobalDataManager sharedInstance];
  
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - accessor
-(UIPanGestureRecognizer*)splitViewPanGestureRecognizer {
    if (!_splitViewPanGestureRecognizer) {
        for (UIGestureRecognizer* recognizer in [self.view gestureRecognizers]) {
            if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                _splitViewPanGestureRecognizer = (UIPanGestureRecognizer *) recognizer;
            }
        }
        
    }
    return _splitViewPanGestureRecognizer;
  
}

-(void)viewWillDisappear:(BOOL)animated {
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
