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
}

- (void)setProjectId:(NSNumber *)projectId
{
    _projectId = projectId;

    [self.viewControllers setValue:projectId forKey:@"projectId"];
}

- (void)setPackageVersionId:(NSNumber *)packageVersionId
{
    _packageVersionId = packageVersionId;

    [self.viewControllers setValue:packageVersionId forKey:@"packageVersionId"];
}

- (void)setPackageMasterId:(NSNumber *)packageMasterId
{
    _packageMasterId = packageMasterId;

    [self.viewControllers setValue:packageMasterId forKey:@"packageMasterId"];
}

@end
