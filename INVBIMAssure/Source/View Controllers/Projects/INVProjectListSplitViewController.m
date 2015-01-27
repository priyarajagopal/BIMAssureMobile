 //
//  INVProjectListSplitViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectListSplitViewController.h"
#import "INVProjectsTableViewController.h"

#import "INVMainViewController.h"
#import "INVSplitViewControllerAggregateDelegate.h"

#define ENABLE_ALL_VISIBLE 1

@interface INVProjectListSplitViewController ()<UISplitViewControllerDelegate, UIGestureRecognizerDelegate>


@end

@implementation INVProjectListSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.preferredDisplayMode =  UISplitViewControllerDisplayModeAllVisible;
    self.splitViewPanGestureRecognizer.delegate = self;
    self.presentsWithGesture = NO;
    
    self.aggregateDelegate = [INVSplitViewControllerAggregateDelegate new];
    self.aggregateDelegate.splitViewController = self;
    
    self.delegate = self.aggregateDelegate;
}

#if !ENABLE_ALL_VISIBLE

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Base64 encoded primaryDimmingView
    NSData *data = [[NSData alloc] initWithBase64EncodedString:@"cHJpbWFyeURpbW1pbmdWaWV3" options:0];
    NSString *key = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    INVMainViewController *mainViewController = (INVMainViewController *) self.parentViewController;
    id dimmingView = [self valueForKey:key];
    
    [dimmingView setPassthroughViews:@[
        mainViewController.mainMenuContainerView
    ]];
}

-(id) valueForUndefinedKey:(NSString *)key {
    NSLog(@"Warning - undefined key requested! %@", key);
    return nil;
}

#endif

#pragma mark - UISplitViewControllerDelegate

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.    
}

-(void) setSelectedProject:(INVProject *)project {
    UINavigationController *navController = [self.viewControllers firstObject];
    [[[navController childViewControllers] firstObject] setSelectedProject:project];
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
