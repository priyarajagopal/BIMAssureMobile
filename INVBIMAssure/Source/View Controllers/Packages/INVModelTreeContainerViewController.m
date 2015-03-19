//
//  INVModelTreeContainerViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelTreeContainerViewController.h"
#import "INVModelTreeBuildingElementsTableViewController.h"
#import "NSObject+INVCustomizations.h"

@interface INVModelTreeContainerViewController () <UITabBarControllerDelegate>

@end

@implementation INVModelTreeContainerViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self bindKeyPath:@"packageVersionId" toObject:self keyPath:@"viewControllers.packageVersionId"];
}

@end
