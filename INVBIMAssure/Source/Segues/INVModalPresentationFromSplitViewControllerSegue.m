//
//  INVModalPresentationFromSplitViewControllerSegue.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModalPresentationFromSplitViewControllerSegue.h"

@implementation INVModalPresentationFromSplitViewControllerSegue

-(void) perform {
    // Get the root view controller of the key window
    UIViewController *source = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UISplitViewController *splitViewController = [self.sourceViewController splitViewController];
    
    [source presentViewController:self.destinationViewController animated:YES completion:nil];
    
    if (splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
        // Hide the side-bar
        UIBarButtonItem *barButtonItem = splitViewController.displayModeButtonItem;
        
        // Fake the button being pressed, so we can hide the sidebar.
        // If we do not hide it here, then the sidebar will overlay our modal view controller,
        // which is a bad thing.
        [[UIApplication sharedApplication] sendAction:barButtonItem.action
                                                   to:barButtonItem.target
                                                 from:barButtonItem
                                             forEvent:nil];
    }
}

@end
