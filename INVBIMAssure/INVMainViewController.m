//
//  INVMainViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/14/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVMainViewController.h"
#import "INVMainMenuViewController.h"
#import "INVProjectListSplitViewController.h"

@interface INVMainViewController ()
@property (nonatomic,assign)BOOL registeredForMainMenuEvents;
@property (nonatomic,strong)INVMainMenuViewController* mainMenuVC;
@property (nonatomic,strong)UIViewController* detailContainerViewController;
@end

@implementation INVMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSegueWithIdentifier:@"MainProjectEmbedSegue" sender:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self deregisterMainMenuObservers];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"MainMenuEmbedSegue"]) {
        self.mainMenuVC = segue.destinationViewController;
        [self registerMainMenuObservers];
    }
    else if ([segue.identifier isEqualToString:@"MainProjectEmbedSegue"]) {
        if (self.childViewControllers.count > 1) {
            [self swapFromViewController:[self.childViewControllers objectAtIndex:1] toViewController:segue.destinationViewController];
        }
        else {
            self.detailContainerViewController = segue.destinationViewController;
            [self addChildViewController: self.detailContainerViewController];
            self.detailContainerViewController.view.frame = self.detailContainerView.bounds;
            [self.detailContainerView addSubview:self.detailContainerViewController.view];
            [self.detailContainerViewController didMoveToParentViewController:self];
        }
    }
    else{
        [self swapFromViewController:self.detailContainerViewController toViewController:segue.destinationViewController];
   
    }
}


#pragma mark - helpers
-(void)registerMainMenuObservers {
    if (self.registeredForMainMenuEvents) {
        return;
    }
    self.registeredForMainMenuEvents = YES;
    [self.mainMenuVC addObserver:self forKeyPath:INV_KVO_ONACCOUNTSMENUSELECTED options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:INV_KVO_ONPROJECTSMENUSELECTED options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:INV_KVO_ONUSERPROFILEMENUSELECTED options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:INV_KVO_ONSETTINGSMENUSELECTED options:NSKeyValueObservingOptionNew context:nil];
    
}

-(void)deregisterMainMenuObservers {
    if (!self.registeredForMainMenuEvents) {
        return;
    }
    self.registeredForMainMenuEvents = NO;
    [self.mainMenuVC removeObserver:self forKeyPath:INV_KVO_ONACCOUNTSMENUSELECTED];
    [self.mainMenuVC removeObserver:self forKeyPath:INV_KVO_ONPROJECTSMENUSELECTED ];
    [self.mainMenuVC removeObserver:self forKeyPath:INV_KVO_ONUSERPROFILEMENUSELECTED];
    [self.mainMenuVC removeObserver:self forKeyPath:INV_KVO_ONSETTINGSMENUSELECTED];
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = self.detailContainerView.bounds;
    [self addChildViewController:toViewController];
    
    [fromViewController willMoveToParentViewController:nil];
    
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        self.detailContainerViewController = toViewController;
    }];
    

}

#pragma mark - KVO Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%s. with keyPath %@",__func__,keyPath);
    if ([keyPath isEqualToString:INV_KVO_ONPROJECTSMENUSELECTED]) {
        [self performSegueWithIdentifier:@"MainProjectEmbedSegue" sender:nil];
        
    }
    if ([keyPath isEqualToString:INV_KVO_ONACCOUNTSMENUSELECTED]) {
        [self performSegueWithIdentifier:@"MainAccountEmbedSegue" sender:nil];
        
    }
}

@end
