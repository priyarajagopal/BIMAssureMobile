//
//  INVSplitViewControllerAggregateDelegate.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/27/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVSplitViewControllerAggregateDelegate.h"

@interface INVSplitViewControllerAggregateDelegate ()

@property NSMutableArray *delegates;

@end

@implementation INVSplitViewControllerAggregateDelegate

- (id)init
{
    if (self = [super init]) {
        _delegates = [NSMutableArray new];
    }

    return self;
}

- (void)setSplitViewController:(UISplitViewController *)splitViewController
{
    _splitViewController.delegate = nil;
    _splitViewController = splitViewController;

    _splitViewController.delegate = self;
}

- (void)addDelegate:(id<UISplitViewControllerDelegate>)delegate
{
    [_delegates addObject:delegate];

    self.splitViewController.delegate = nil;
    self.splitViewController.delegate = self;
}

- (void)removeDelegate:(id<UISplitViewControllerDelegate>)delegate
{
    [_delegates removeObject:delegate];

    self.splitViewController.delegate = nil;
    self.splitViewController.delegate = self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }

    if (aSelector == @selector(addDelegate:) || aSelector == @selector(removeDelegate:)) {
        return YES;
    }

    // Obviously if we didn't check the superclass this would report all of the UISplitViewControllerDelegate methods.
    return [[self superclass] instancesRespondToSelector:aSelector];
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate splitViewController:svc willChangeToDisplayMode:displayMode];
        }
    }
}

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc
{
    BOOL hasResults = NO;
    UISplitViewControllerDisplayMode displayMode = UISplitViewControllerDisplayModeAutomatic;

    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            UISplitViewControllerDisplayMode delegateMode = [delegate targetDisplayModeForActionInSplitViewController:svc];

            // Take the first delegate that doesn't use 'automatic'
            if (!hasResults) {
                displayMode = delegateMode;
                hasResults = YES;
            }
        }
    }

    return displayMode;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
         showViewController:(UIViewController *)vc
                     sender:(id)sender
{
    BOOL hasResults = NO;
    BOOL results = NO;

    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            BOOL delegateResults = [delegate splitViewController:splitViewController showViewController:vc sender:sender];

            if (!hasResults) {
                results = delegateResults;
                hasResults = YES;
            }
        }
    }

    return results;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
    showDetailViewController:(UIViewController *)vc
                      sender:(id)sender
{
    BOOL hasResults = NO;
    BOOL results = NO;

    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            BOOL delegateResults = [delegate splitViewController:splitViewController showDetailViewController:vc sender:sender];

            if (!hasResults) {
                results = delegateResults;
                hasResults = YES;
            }
        }
    }

    return results;
}

- (UIViewController *)primaryViewControllerForCollapsingSplitViewController:(UISplitViewController *)splitViewController
{
    BOOL hasResults = NO;
    UIViewController *results = nil;

    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            UIViewController *delegateResults =
                [delegate primaryViewControllerForCollapsingSplitViewController:splitViewController];

            if (!hasResults) {
                results = delegateResults;
                hasResults = YES;
            }
        }
    }

    return results;
}

- (UIViewController *)primaryViewControllerForExpandingSplitViewController:(UISplitViewController *)splitViewController
{
    BOOL hasResults = NO;
    UIViewController *results = nil;

    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            UIViewController *delegateResults =
                [delegate primaryViewControllerForExpandingSplitViewController:splitViewController];

            if (!hasResults) {
                results = delegateResults;
                hasResults = YES;
            }
        }
    }

    return results;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
    collapseSecondaryViewController:(UIViewController *)secondaryViewController
          ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    BOOL hasResults = NO;
    BOOL results = NO;

    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            BOOL delegateResults = [delegate splitViewController:splitViewController
                                 collapseSecondaryViewController:secondaryViewController
                                       ontoPrimaryViewController:primaryViewController];

            if (!hasResults) {
                results = delegateResults;
                hasResults = YES;
            }
        }
    }

    return results;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController
    separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    BOOL hasResults = NO;
    UIViewController *results = nil;

    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            UIViewController *delegateResults = [delegate splitViewController:splitViewController
                     separateSecondaryViewControllerFromPrimaryViewController:primaryViewController];

            if (!hasResults) {
                results = delegateResults;
                hasResults = YES;
            }
        }
    }

    return results;
}

- (NSUInteger)splitViewControllerSupportedInterfaceOrientations:(UISplitViewController *)splitViewController
{
    BOOL hasResults = NO;
    NSUInteger results = 0;

    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            NSUInteger delegateResults = [delegate splitViewControllerSupportedInterfaceOrientations:splitViewController];

            if (!hasResults) {
                results = delegateResults;
                hasResults = YES;
            }
        }
    }

    return results;
}

- (UIInterfaceOrientation)splitViewControllerPreferredInterfaceOrientationForPresentation:
        (UISplitViewController *)splitViewController
{
    BOOL hasResults = NO;
    UIInterfaceOrientation results = 0;

    for (id<NSObject, UISplitViewControllerDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            UIInterfaceOrientation delegateResults =
                [delegate splitViewControllerPreferredInterfaceOrientationForPresentation:splitViewController];

            if (!hasResults) {
                results = delegateResults;
                hasResults = YES;
            }
        }
    }

    return results;
}

@end
