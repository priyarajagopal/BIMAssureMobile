//
//  INVProjectEditViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVProjectEditViewController;
@protocol INVProjectEditViewControllerDelegate <NSObject>

@optional
-(void) onProjectEditCancelled:(INVProjectEditViewController *) controller;
-(void) onProjectEditSaved:(INVProjectEditViewController *) controller;

@end

@interface INVProjectEditViewController : UITableViewController

@property (nonatomic, weak) id<INVProjectEditViewControllerDelegate> delegate;
@property (nonatomic) INVProject *currentProject;

@end
