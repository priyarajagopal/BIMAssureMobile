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
#import "INVAccountListViewController.h"

@interface INVMainViewController ()
@property (nonatomic,assign)BOOL registeredForMainMenuEvents;
@property (nonatomic,strong)INVMainMenuViewController* mainMenuVC;
@property (nonatomic,strong)UIViewController* detailContainerViewController;
@end

@implementation INVMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setDetailViewConstraints];
    [self performSegueWithIdentifier:@"MainProjectEmbedSegue" sender:nil];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self deregisterMainMenuObservers];
    self.detailContainerViewController = nil;
    self.mainMenuVC = nil;
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
            [self addChildViewController: segue.destinationViewController];
            ((UIViewController*)segue.destinationViewController).view.frame = self.detailContainerView.bounds;
            [self.detailContainerView addSubview:((UIViewController*)segue.destinationViewController).view];
            [segue.destinationViewController didMoveToParentViewController:self];
                    }
    }
    else if ([segue.identifier isEqualToString:@"MainAccountEmbedSegue"]) {
        [self swapFromViewController:self.detailContainerViewController toViewController:segue.destinationViewController];
   
    }
}

-(IBAction)done:(UIStoryboardSegue*)segue {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - helpers
-(void) setDetailViewConstraints {
  //  NSLayoutConstraint* xConstraint = [NSLayoutConstraint constraintWithItem:self.detailContainerView attribute:NSLayoutAttributeLeftMargin relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:85];
  //  NSLayoutConstraint* yConstraint = [NSLayoutConstraint constraintWithItem:self.detailContainerView attribute:NSLayoutAttributeTopMargin relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];

  //  [self.detailContainerViewController.view addConstraints:@[xConstraint,yConstraint]];
    
}
-(void)registerMainMenuObservers {
    if (self.registeredForMainMenuEvents) {
        return;
    }
    self.registeredForMainMenuEvents = YES;
    
    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnAccountMenuSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnProjectsMenuSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnUserProfileMenuSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnInfoMenuSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnLogoutMenuSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnManageUsersMenuSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnNotificationsMenuSelected options:NSKeyValueObservingOptionNew context:nil];
}

-(void)deregisterMainMenuObservers {
    if (!self.registeredForMainMenuEvents) {
        return;
    }
    self.registeredForMainMenuEvents = NO;
    
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnAccountMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnProjectsMenuSelected ];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnUserProfileMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnInfoMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnLogoutMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnManageUsersMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnNotificationsMenuSelected];
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = self.detailContainerView.bounds;
    [self addChildViewController:toViewController];
    
    [self.detailContainerView addSubview:toViewController.view];
    
    toViewController.view.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        fromViewController.view.alpha = 0;
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        
        self.detailContainerViewController = toViewController;
    }];
}

#pragma mark - KVO Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%s. with keyPath %@",__func__,keyPath);
    NSLog(@"%@", self.detailContainerViewController.class);
    
    if ([keyPath isEqualToString:KVO_INVOnProjectsMenuSelected]) {
        if (![self.detailContainerViewController isKindOfClass:[INVProjectListSplitViewController class]]) {
            [self performSegueWithIdentifier:@"MainProjectEmbedSegue" sender:nil];
        }
    }
    
    if ([keyPath isEqualToString:KVO_INVOnAccountMenuSelected]) {
    
        if ([self.detailContainerViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *) self.detailContainerViewController;
            
            if ([[navigationController.viewControllers firstObject] isKindOfClass:[INVAccountListViewController class]]) {
                return;
            }
        }
        
        [self performSegueWithIdentifier:@"MainAccountEmbedSegue" sender:nil];
        
    }
    if ([keyPath isEqualToString:KVO_INVOnLogoutMenuSelected]) {
        [self performSegueWithIdentifier:@"MainLogoutSegue" sender:nil];
        
    }
    if ([keyPath isEqualToString:KVO_INVOnManageUsersMenuSelected]) {
        [self.userMgmtTransitionObject perform:nil];
        
    }
    if ([keyPath isEqualToString:KVO_INVOnInfoMenuSelected]) {
        [self.infoTransitionObject perform:nil];
    }
    
    if ([keyPath isEqualToString:KVO_INVOnNotificationsMenuSelected]) {
        [self.notificationsTransitionObject perform:nil];
    }
}

@end
