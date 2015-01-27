//
//  INVModalPresentationFromSplitViewControllerSegue.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModalPresentationFromSplitViewControllerSegue.h"
#import "UISplitViewController+ToggleSidebar.h"

@implementation INVModalPresentationFromSplitViewControllerSegue

-(void) perform {
    // Get the root view controller of the key window
    UIViewController *source = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UISplitViewController *splitViewController = [self.sourceViewController splitViewController];
    
    [source presentViewController:self.destinationViewController animated:YES completion:nil];
    
    if (splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
        [splitViewController toggleSidebar];
    }
}

@end
