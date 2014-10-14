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

@interface AppDelegate ()
@property (nonatomic,assign)BOOL registeredForLoginEvents;
@property (nonatomic,assign)BOOL registeredForAccountEvents;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registerLoginObservers];
    [self setUpViewAppearance];
     return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - view appearance
-(void) setUpViewAppearance {
    UIColor * whiteColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
    UIColor * darkGreyColor = [UIColor colorWithRed:106.0/255 green:106.0/255 blue:106.0/255 alpha:1.0];
    UIColor * ltGreyColor = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
  
    
    [self.window setTintColor:darkGreyColor];
    [[UINavigationBar appearance] setBarTintColor: darkGreyColor] ;
    [[UINavigationBar appearance] setTintColor:whiteColor] ;
    
    [[UIBarButtonItem appearance] setTintColor:whiteColor];
    [[UITextField appearance] setTintColor:darkGreyColor];
    [[UIView appearance] setTintColor:whiteColor];
    [[UITabBar appearance]setBarTintColor:ltGreyColor];
    [[UITabBar appearance]setTintColor:darkGreyColor];
     
}

#pragma mark - VC management

-(void)displayLoggedInRootViewController {
    [self deregisterLoginObservers];
    UINavigationController* accountListNC = [[self mainStoryboard]instantiateViewControllerWithIdentifier:@"AccountListNC"];
     self.window.rootViewController = accountListNC;
    [self registerAccountObservers];
    
}


-(void)displayLoginRootViewController {
    [self deregisterAccountObservers];

    INVLoginViewController* loginVC = [[self mainStoryboard]instantiateViewControllerWithIdentifier:@"LoginVC"];
     self.window.rootViewController = loginVC;
    [self registerLoginObservers];

}

-(void)displayProjectsListRootViewController {
    [self deregisterAccountObservers];
    [self deregisterLoginObservers];
    INVProjectListSplitViewController* projectsVC = [[self mainStoryboard]instantiateViewControllerWithIdentifier:@"ProjectListSplitVC"];
    projectsVC.preferredDisplayMode =  UISplitViewControllerDisplayModeAllVisible;
    self.window.rootViewController = projectsVC;
    
}

#pragma mark - helpers
-(void)registerLoginObservers {
    if ([[self rootController] isKindOfClass:[INVLoginViewController class]]) {
        if (!self.registeredForLoginEvents) {
            self.registeredForLoginEvents = YES;
            INVLoginViewController* loginVC = (INVLoginViewController*) [self rootController];
            [loginVC addObserver:self forKeyPath:KVO_INV_LoginSuccess options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

-(void) deregisterLoginObservers {
    if (self.registeredForLoginEvents) {
        self.registeredForLoginEvents = NO;
        INVLoginViewController* loginVC = (INVLoginViewController*) [self rootController];
        [loginVC removeObserver:self forKeyPath:KVO_INV_LoginSuccess];
    }
}

-(void)registerAccountObservers {
    if ([[self rootController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController* rootVC = (UINavigationController*) [self rootController];
        if ([rootVC.topViewController isKindOfClass:[INVAccountListViewController class]]) {
        if (!self.registeredForAccountEvents) {
            self.registeredForAccountEvents = YES;
            [rootVC.topViewController addObserver:self forKeyPath:KVO_INV_AccountLoginSuccess options:NSKeyValueObservingOptionNew context:nil];
        }
        }
    }
}

-(void) deregisterAccountObservers {
    if (self.registeredForAccountEvents) {
        self.registeredForAccountEvents = NO;
        UINavigationController* rootVC = (UINavigationController*) [self rootController];
        [rootVC.topViewController removeObserver:self forKeyPath:KVO_INV_AccountLoginSuccess];
    }
}


-(UIViewController*)rootController {
    return self.window.rootViewController;
}


-(UIStoryboard*)mainStoryboard {
    return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:[self class]]];
}




#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%s. Keypath %@: %@: %@",__func__,keyPath,object,change);
    if ([keyPath isEqualToString:KVO_INV_LoginSuccess]) {
        INVLoginViewController* loginVC = (INVLoginViewController*) object;
        if (loginVC.loginSuccess) {
            [self displayLoggedInRootViewController];
        }
    }
    else if ([keyPath isEqualToString:KVO_INV_AccountLoginSuccess]) {
        INVAccountListViewController* accountVC = (INVAccountListViewController*) object;
        if (accountVC.accountLoginSuccess) {
            [self displayProjectsListRootViewController];
        }
        
    }
    
}
@end
