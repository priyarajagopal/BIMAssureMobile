//
//  INVModelViewerContainerViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INVModelViewerViewController2.h"
#import "INVModelTreeBuildingElementsTableViewController.h"

@interface INVModelViewerContainerViewController : UIViewController

@property (nonatomic, strong) NSNumber *projectId;
@property (nonatomic, strong) NSNumber *packageMasterId;
@property (nonatomic, strong) NSNumber *fileVersionId;
@property (nonatomic, strong) NSNumber *modelId;

- (void)highlightElement:(NSString *)elementId;

@end
