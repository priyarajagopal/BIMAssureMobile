//
//  AppDelegate.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "INVLoginViewController.h"
#import "INVAccountListViewController.h"
#import "INVProjectListSplitViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import AddressBookUI;

#import "INVNotificationPoller.h"
#import "INVPendingInvitesNotificationDataSource.h"
#import "INVProjectsNotificationDataSource.h"

@interface AppDelegate ()
@property (nonatomic, assign) BOOL registeredForLoginEvents;
@property (nonatomic, assign) BOOL registeredForAccountEvents;
@property (nonatomic, weak) INVGlobalDataManager *globalManager;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.globalManager = [INVGlobalDataManager sharedInstance];
    if ([self isFirstRunOfApp]) {
        [self.globalManager deleteCurrentlySavedCredentialsFromKC];
        [self.globalManager deleteCurrentlySavedDefaultAccountFromKC];
    }
    [self enableCrashReporting];
    [self setupNetworkCache];
    [self registerGlobalNotifications];
    [self prepareNotificationPolling];

    [self displayLoginRootViewController];
    [self setUpViewAppearance];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary
    // interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the
    // transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this
    // method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state
    // information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the
    // user quits.
    [self resetRootViewControllerWhenAppPushedToBackground];
    [self deregisterGlobalNotifications];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on
    // entering the background.
    [self registerGlobalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was
    // previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - view appearance
- (void)setUpViewAppearance
{
    UIColor *whiteColor = [UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:255.0 / 255 alpha:1.0];
    UIColor *medGreyColor = [UIColor colorWithRed:225.0 / 255 green:225.0 / 255 blue:225.0 / 255 alpha:1.0];
    UIColor *ltGreyColor = [UIColor colorWithRed:245.0 / 255 green:245.0 / 255 blue:245.0 / 255 alpha:1.0];
    UIColor *darkGreyColor = [UIColor colorWithRed:150.0 / 255 green:150.0 / 255 blue:150.0 / 255 alpha:1.0];
    UIColor *cyanBlueColor = [UIColor colorWithRed:38.0 / 255 green:138.0 / 255 blue:171.0 / 255 alpha:1.0];

    [[UIView appearance] setTintColor:whiteColor];
    [self.window setTintColor:whiteColor];

    [[UINavigationBar appearance] setBarTintColor:cyanBlueColor];
    [[UINavigationBar appearance] setTintColor:whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : whiteColor}];

    [[UIBarButtonItem appearance] setTintColor:whiteColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTintColor:[UIColor redColor]];
    [[UITextField appearance] setTintColor:darkGreyColor];

    [[UIView appearanceWhenContainedIn:[UITabBar class], nil] setTintColor:[UIColor darkGrayColor]];
    [[UITabBar appearance] setBarTintColor:ltGreyColor];
    [[UITabBar appearance] setTintColor:cyanBlueColor];

    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:darkGreyColor];

    [[UITableView appearanceWhenContainedIn:[UITableViewController class], nil] setTintColor:darkGreyColor];
    [[UICollectionView appearanceWhenContainedIn:[UICollectionViewController class], nil] setTintColor:darkGreyColor];

    // ABPeoplePicker overrides
    [[UIView appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTintColor:darkGreyColor];

    [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setBarTintColor:cyanBlueColor];
    [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTintColor:whiteColor];
    [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil]
        setTitleTextAttributes:@{NSForegroundColorAttributeName : whiteColor}];

    // This is for the back indicator
    [[UIImageView appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTintColor:whiteColor];
}

#pragma mark - VC management

- (void)resetRootViewControllerWhenAppPushedToBackground
{
    [self deregisterAccountObservers];
    [self deregisterLoginObservers];
    [self.globalManager.invServerClient logOffSignedInUserWithCompletionBlock:^(INVEmpireMobileError *error) {
        self.globalManager.loggedInAccount = nil;
        [self displayLoginRootViewController];
    }];
}

- (void)displayLoggedInRootViewController
{
    [self deregisterLoginObservers];
    UINavigationController *accountListNC = [[self accountStoryboard] instantiateViewControllerWithIdentifier:@"AccountListNC"];
    self.window.rootViewController = accountListNC;
    INVAccountListViewController *accountListVC = (INVAccountListViewController *) accountListNC.topViewController;
    accountListVC.autoSignIntoDefaultAccount = YES;
    [self registerAccountObservers];
}

- (void)displayLoginRootViewController
{
    [self deregisterAccountObservers];

    INVLoginViewController *loginVC = [[self loginStoryboard] instantiateViewControllerWithIdentifier:@"LoginVC"];
    self.window.rootViewController = loginVC;

    [self registerLoginObservers];
}

- (void)displayProjectsListRootViewController
{
    [self deregisterAccountObservers];
    [self deregisterLoginObservers];

    UIViewController *projectsVC = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"MainVC"];
    self.window.rootViewController = projectsVC;
}

#pragma mark - helpers
- (void)enableCrashReporting
{
    [Fabric with:@[ CrashlyticsKit ]];
}
- (void)registerLoginObservers
{
    if ([[self rootController] isKindOfClass:[INVLoginViewController class]]) {
        if (!self.registeredForLoginEvents) {
            self.registeredForLoginEvents = YES;
            INVLoginViewController *loginVC = (INVLoginViewController *) [self rootController];
            [loginVC addObserver:self forKeyPath:KVO_INVLoginSuccess options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)deregisterLoginObservers
{
    if (self.registeredForLoginEvents) {
        self.registeredForLoginEvents = NO;
        INVLoginViewController *loginVC = (INVLoginViewController *) [self rootController];
        [loginVC removeObserver:self forKeyPath:KVO_INVLoginSuccess];
    }
}

- (void)registerAccountObservers
{
    if ([[self rootController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *rootVC = (UINavigationController *) [self rootController];
        if ([rootVC.topViewController isKindOfClass:[INVAccountListViewController class]]) {
            if (!self.registeredForAccountEvents) {
                self.registeredForAccountEvents = YES;
                [rootVC.topViewController addObserver:self
                                           forKeyPath:KVO_INVAccountLoginSuccess
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
            }
        }
    }
}

- (void)deregisterAccountObservers
{
    if (self.registeredForAccountEvents) {
        self.registeredForAccountEvents = NO;
        UINavigationController *rootVC = (UINavigationController *) [self rootController];
        [rootVC.topViewController removeObserver:self forKeyPath:KVO_INVAccountLoginSuccess];
    }
}

- (void)registerGlobalNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserLogOut:)
                                                 name:INV_NotificationUserLogOutSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAccountSwitch:)
                                                 name:INV_NotificationAccountSwitchSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAccountLogOut:)
                                                 name:INV_NotificationAccountLogOutSuccess
                                               object:nil];
}

- (void)deregisterGlobalNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INV_NotificationUserLogOutSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INV_NotificationAccountSwitchSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INV_NotificationAccountLogOutSuccess object:nil];
}

- (void)prepareNotificationPolling
{
    [[INVNotificationPoller instance] addDataSource:[INVPendingInvitesNotificationDataSource new]];
    [[INVNotificationPoller instance] addDataSource:[INVProjectsNotificationDataSource new]];
    [[INVNotificationPoller instance] beginPolling];
}

- (UIViewController *)rootController
{
    return self.window.rootViewController;
}

- (UIStoryboard *)accountStoryboard
{
    return [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle bundleForClass:[self class]]];
}

- (UIStoryboard *)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:[self class]]];
}

- (UIStoryboard *)loginStoryboard
{
    return [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle bundleForClass:[self class]]];
}

- (BOOL)isFirstRunOfApp
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"INV_FirstTimeLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"INV_FirstTimeLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

#pragma mark - KVO Handling
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    INVLogDebug(@"Keypath '%@' of object '%@' changed with info: %@", keyPath, object, change);

    if ([keyPath isEqualToString:KVO_INVLoginSuccess]) {
        INVLoginViewController *loginVC = (INVLoginViewController *) object;
        if (loginVC.loginSuccess) {
            [self displayLoggedInRootViewController];
        }
    }
    else if ([keyPath isEqualToString:KVO_INVAccountLoginSuccess]) {
        INVAccountListViewController *accountVC = (INVAccountListViewController *) object;
        if (accountVC.accountLoginSuccess) {
            [self displayProjectsListRootViewController];
        }
    }
}

#pragma mark - Notification Handlers
- (void)onUserLogOut:(NSNotification *)notification
{
    INVLogDebug(@"User logged out");

    [self displayLoginRootViewController];
}

- (void)onAccountLogOut:(NSNotification *)notification
{
    INVLogDebug();

    [self displayLoggedInRootViewController];
}

- (void)onAccountSwitch:(NSNotification *)notification
{
    INVLogDebug(@"Notification: %@", notification);

    [self displayProjectsListRootViewController];
}

#pragma mark - Global Config
- (void)setupNetworkCache
{
}

@end
