//
//  INVModelTreeNodePropertiesTableViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/3/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INVBlackTintedTableViewController.h"

@interface INVBuildingElementPropertiesTableViewController : INVBlackTintedTableViewController

@property NSString *buildingElementCategory;
@property NSNumber *buildingElementId;
@property NSString *buildingElementName;

@property NSNumber *packageVersionId;

@end
