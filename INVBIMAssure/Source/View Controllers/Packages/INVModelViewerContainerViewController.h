//
//  INVModelViewerContainerViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INVModelViewerViewController.h"

@interface INVModelViewerContainerViewController : UIViewController

@property (nonatomic, strong) INVModelViewerViewController *modelViewController;

@property (nonatomic,strong)NSNumber* fileVersionId;
@property (nonatomic,strong)NSNumber* modelId;

@end
