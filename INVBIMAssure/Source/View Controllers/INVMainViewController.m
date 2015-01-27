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

@interface INVMainViewController ()<UIPopoverPresentationControllerDelegate>

@property (nonatomic) BOOL shouldPresentProjectsSidebar;
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

-(IBAction) done:(UIStoryboardSegue *) segue {
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.detailContainerViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitViewController = (UISplitViewController *) self.detailContainerViewController;
        
        if (splitViewController.displayMode != UISplitViewControllerDisplayModePrimaryHidden) {
            UIBarButtonItem *barButtonItem = splitViewController.displayModeButtonItem;
            
            [[UIApplication sharedApplication] sendAction:barButtonItem.action
                                                       to:barButtonItem.target
                                                     from:barButtonItem
                                                 forEvent:nil];
            
            self.shouldPresentProjectsSidebar = YES;
        }
        
        if ([segue.identifier isEqualToString:@"MainLogoutSegue"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[segue.destinationViewController popoverPresentationController] setDelegate:self];
            });
        }
    }
    
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
    } else if ([segue.identifier isEqualToString:@"MainAccountEmbedSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]] &&
            [((UINavigationController*)segue.destinationViewController).topViewController isKindOfClass:[INVAccountListViewController class]]) {
                INVAccountListViewController* accountListVC = (INVAccountListViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
                accountListVC.hideSettingsButton = YES;
            
        }
        
        [self swapFromViewController:self.detailContainerViewController toViewController:segue.destinationViewController];
    }
}

-(IBAction) manualDismiss:(UIStoryboardSegue*)segue {
    // Known bug: http://stackoverflow.com/questions/25654941/unwind-segue-not-working-in-ios-8
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.userInfoTransitionObject.arrowAnchor = self.mainMenuVC.logoutButton;
    });
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

-(UIStoryboardSegue *) segueForUnwindingToViewController:(UIViewController *)toViewController
                                      fromViewController:(UIViewController *)fromViewController
                                              identifier:(NSString *)identifier {
    UIStoryboardSegue *storyboardSegue = [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
    
    [self popoverPresentationControllerDidDismissPopover:nil];
    
    return storyboardSegue;
}

-(void) popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    if ([self.detailContainerViewController isKindOfClass:[UISplitViewController class]] && self.shouldPresentProjectsSidebar) {
        UISplitViewController *splitViewController = (UISplitViewController *) self.detailContainerViewController;
        UIBarButtonItem *barButtonItem = splitViewController.displayModeButtonItem;
        
        [[UIApplication sharedApplication] sendAction:barButtonItem.action
                                                   to:barButtonItem.target
                                                 from:barButtonItem
                                             forEvent:nil];
        
        self.shouldPresentProjectsSidebar = NO;
    }
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

-(void) viewProject:(INVProject *)project {
    if (![self.detailContainerViewController isKindOfClass:[INVProjectListSplitViewController class]]) {
        [self performSegueWithIdentifier:@"MainProjectEmbedSegue" sender:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        INVProjectListSplitViewController *splitVC = (INVProjectListSplitViewController *) self.detailContainerViewController;
        [splitVC setSelectedProject:project];
    });
}

#pragma mark - KVO Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
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
        
        [self.embedAccountsTransitionObject perform:nil];
        
    }
    if ([keyPath isEqualToString:KVO_INVOnLogoutMenuSelected]) {
        [self.userInfoTransitionObject perform:nil];
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
