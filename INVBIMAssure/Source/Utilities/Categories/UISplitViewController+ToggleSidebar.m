//
//  UISplitViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/27/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "UISplitViewController+ToggleSidebar.h"

@implementation UISplitViewController(ToggleSidebar)

-(void) toggleSidebar {
    UIBarButtonItem *barButtonItem = self.displayModeButtonItem;
    
    [[UIApplication sharedApplication] sendAction:barButtonItem.action
                                               to:barButtonItem.target
                                             from:barButtonItem
                                         forEvent:nil];
}

@end
