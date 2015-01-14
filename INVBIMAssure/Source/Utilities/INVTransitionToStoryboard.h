//
//  TransitionToStoryboard.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/14/15.
//  Copyright (c) 2015 Invicara. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

typedef NS_ENUM(NSInteger, StoryboardTransition) {
    StoryboardTransitionShow       = 0,
    StoryboardTransitionShowDetail = 1,
    StoryboardTransitionModal      = 2,
    StoryboardTransitionPopover    = 3,
    StoryboardTransitionCustom     = 4
};

@interface INVTransitionToStoryboard : NSObject

@property IBOutlet UIViewController *sourceViewController;
@property IBInspectable NSString *identifier;

@property IBInspectable NSString *targetStoryboard;
@property IBInspectable NSString *targetIdentifier;

// One of StoryboardTransition
@property IBInspectable NSInteger transitionType;

// Transition type 2 - modal
@property IBInspectable NSInteger modalPresentationStyle;
@property IBInspectable NSInteger modalTransitionStyle;

// Transition type 3 - popover
@property IBInspectable NSInteger arrowDirection;
@property IBOutlet UIView *arrowAnchor;
@property IBOutletCollection(UIView) NSArray *passthroughViews;

// Transition type 4 - custom
@property IBInspectable NSString *customSegueClass;

-(IBAction) perform:(id)sender;


@end
