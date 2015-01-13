//
//  INVModalPresentationFromSplitViewControllerSegue.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Due to a bug with how iOS manages split view controllers and their panes, 
 * we must have a custom segue to manage the transitions from any segue triggered 
 * inside of a split view controller's master pane.
 * 
 * This simply modally presents the view controller using the default presentation
 * style set by the target view controller.
 *
 * To explain the bug:
 * When a UISplitViewController presents its sidebar modally (using the displayMode property),
 * it creates its own UIWindow for the sidebar view controller to reside in. 
 *
 * When this happens, any unwind segues go to that new window and its view controller stack, 
 * and *not* to the unwind segue stack in the master view controller, which is what is expected 
 * by both the storyboard and the runtime.
 *
 * To fix this, we simply use this segue to force the view controller to be presented from 
 * the main window of the application, and not from the window used by the split view controller.
 */
@interface INVModalPresentationFromSplitViewControllerSegue : UIStoryboardSegue

@end
