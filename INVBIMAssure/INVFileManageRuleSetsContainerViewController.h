//
//  INVFileManageRuleSetsContainerViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomViewController.h"

@interface INVFileManageRuleSetsContainerViewController : INVCustomViewController
- (IBAction)onResetTapped:(UIBarButtonItem *)sender;

@property (nonatomic,strong) NSNumber* projectId;
@property (nonatomic,assign) NSNumber* fileId;
@end