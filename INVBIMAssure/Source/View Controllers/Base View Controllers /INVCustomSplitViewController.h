//
//  INVCustomSplitViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVCustomSplitViewController : UISplitViewController
@property (nonatomic, readonly) INVGlobalDataManager *globalDataManager;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, readonly) UIPanGestureRecognizer *splitViewPanGestureRecognizer;

@end
