//
//  INVProjectDetailsTabViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTabBarController.h"

@interface INVProjectDetailsTabViewController : INVCustomTabBarController
@property (weak, nonatomic) IBOutlet INVTabBarStoryboardLoader *storyboardTransitionObject;

- (void)setSelectedProject:(INVProject *)project;

@end
