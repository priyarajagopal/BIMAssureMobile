//
//  INVModelTreeContainerViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTabBarController.h"

@interface INVModelTreeContainerViewController : INVCustomTabBarController

@property (nonatomic) NSNumber *projectId;
@property (nonatomic) NSNumber *packageMasterId;
@property (nonatomic) NSNumber *packageVersionId;

@end
