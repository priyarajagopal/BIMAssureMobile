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
#import "UISplitViewController+ToggleSidebar.h"

@interface INVMainViewController ()

@property (nonatomic) BOOL shouldPresentProjectsSidebar;
@property (nonatomic, assign) BOOL registeredForMainMenuEvents;
@property (nonatomic, strong) INVMainMenuViewController *mainMenuVC;
@property (nonatomic, strong) UIViewController *detailContainerViewController;
@end

@implementation INVMainViewController

- (void)dealloc
{
    [self deregisterMainMenuObservers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self setDetailViewConstraints];
    [self performSegueWithIdentifier:@"MainProjectEmbedSegue" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.detailContainerViewController = nil;
    self.mainMenuVC = nil;
}

#pragma mark - Navigation

- (IBAction)done:(UIStoryboardSegue *)segue
{
}

- (IBAction)manualDismiss:(UIStoryboardSegue *)segue
{
    // Known bug: http://stackoverflow.com/questions/25654941/unwind-segue-not-working-in-ios-8
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideSidebarForPresentingModalView
{
    if (![self.detailContainerViewController isKindOfClass:[UISplitViewController class]]) {
        return;
    }

    UISplitViewController *splitViewController = (UISplitViewController *) self.detailContainerViewController;

    if (splitViewController.preferredDisplayMode == UISplitViewControllerDisplayModeAllVisible) {
        return;
    }

    if (splitViewController.displayMode != UISplitViewControllerDisplayModePrimaryHidden) {
        [splitViewController toggleSidebar];

        self.shouldPresentProjectsSidebar = YES;
    }
}

- (void)showSidebarAfterPresentingModalView
{
    if (![self.detailContainerViewController isKindOfClass:[UISplitViewController class]]) {
        return;
    }

    if (self.shouldPresentProjectsSidebar) {
        UISplitViewController *splitViewController = (UISplitViewController *) self.detailContainerViewController;
        [splitViewController toggleSidebar];

        self.shouldPresentProjectsSidebar = NO;
    }
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion
{
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];

    [self hideSidebarForPresentingModalView];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [super dismissViewControllerAnimated:flag
                              completion:^{
                                  [self showSidebarAfterPresentingModalView];

                                  if (completion)
                                      completion();
                              }];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"MainMenuEmbedSegue"]) {
        self.mainMenuVC = segue.destinationViewController;

        [self registerMainMenuObservers];
    }
    else if ([segue.identifier isEqualToString:@"MainProjectEmbedSegue"]) {
        if (self.childViewControllers.count > 1) {
            [self swapFromViewController:[self.childViewControllers objectAtIndex:1]
                        toViewController:segue.destinationViewController];
        }
        else {
            self.detailContainerViewController = segue.destinationViewController;
            [self addChildViewController:segue.destinationViewController];
            ((UIViewController *) segue.destinationViewController).view.frame = self.detailContainerView.bounds;
            [self.detailContainerView addSubview:((UIViewController *) segue.destinationViewController).view];
            [segue.destinationViewController didMoveToParentViewController:self];
        }
    }
    else if ([segue.identifier isEqualToString:@"MainAccountEmbedSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]] &&
            [((UINavigationController *) segue.destinationViewController).topViewController
                isKindOfClass:[INVAccountListViewController class]]) {
            INVAccountListViewController *accountListVC =
                (INVAccountListViewController *) ((UINavigationController *) segue.destinationViewController).topViewController;
            accountListVC.hideSettingsButton = YES;
        }

        [self swapFromViewController:self.detailContainerViewController toViewController:segue.destinationViewController];
    }
}

#pragma mark - helpers
- (void)setDetailViewConstraints
{
    //  NSLayoutConstraint* xConstraint = [NSLayoutConstraint constraintWithItem:self.detailContainerView
    //  attribute:NSLayoutAttributeLeftMargin relatedBy:NSLayoutRelationEqual toItem:nil
    //  attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:85];
    //  NSLayoutConstraint* yConstraint = [NSLayoutConstraint constraintWithItem:self.detailContainerView
    //  attribute:NSLayoutAttributeTopMargin relatedBy:NSLayoutRelationEqual toItem:nil
    //  attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];

    //  [self.detailContainerViewController.view addConstraints:@[xConstraint,yConstraint]];
}

- (void)registerMainMenuObservers
{
    if (self.registeredForMainMenuEvents) {
        [self deregisterMainMenuObservers];
        return;
    }

    self.registeredForMainMenuEvents = YES;

    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnAccountMenuSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self
                      forKeyPath:KVO_INVOnProjectsMenuSelected
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.mainMenuVC addObserver:self
                      forKeyPath:KVO_INVOnUserProfileMenuSelected
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnInfoMenuSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:KVO_INVOnLogoutMenuSelected options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self
                      forKeyPath:KVO_INVOnManageUsersMenuSelected
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.mainMenuVC addObserver:self
                      forKeyPath:KVO_INVOnNotificationsMenuSelected
                         options:NSKeyValueObservingOptionNew
                         context:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.userInfoTransitionObject.arrowAnchor = self.mainMenuVC.logoutButton;
    });
}

- (void)deregisterMainMenuObservers
{
    if (!self.registeredForMainMenuEvents) {
        return;
    }
    self.registeredForMainMenuEvents = NO;

    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnAccountMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnProjectsMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnUserProfileMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnInfoMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnLogoutMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnManageUsersMenuSelected];
    [self.mainMenuVC removeObserver:self forKeyPath:KVO_INVOnNotificationsMenuSelected];
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    if (fromViewController == nil) {
        fromViewController = [UIViewController new];
        fromViewController.view.frame = self.detailContainerView.bounds;

        [self addChildViewController:fromViewController];
        [self.detailContainerView addSubview:fromViewController.view];
    }

    toViewController.view.frame = self.detailContainerView.bounds;
    [self addChildViewController:toViewController];

    self.detailContainerViewController = toViewController;

    toViewController.view.alpha = 0;
    [self transitionFromViewController:fromViewController
        toViewController:toViewController
        duration:0
        options:UIViewAnimationOptionTransitionNone
        animations:^{
            [self.detailContainerView addSubview:toViewController.view];
        }
        completion:^(BOOL finished) {
            [fromViewController removeFromParentViewController];

            [UIView animateWithDuration:0.5
                             animations:^{
                                 toViewController.view.alpha = 1;
                             }
                             completion:nil];
        }];
}

- (void)viewProject:(INVProject *)project
{
    if (![self.detailContainerViewController isKindOfClass:[INVProjectListSplitViewController class]]) {
        [self performSegueWithIdentifier:@"MainProjectEmbedSegue" sender:nil];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        INVProjectListSplitViewController *splitVC = (INVProjectListSplitViewController *) self.detailContainerViewController;
        [splitVC setSelectedProject:project];
    });
}

#pragma mark - KVO Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
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
