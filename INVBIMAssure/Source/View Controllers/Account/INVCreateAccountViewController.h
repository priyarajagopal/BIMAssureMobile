//
//  INVCreateAccountViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 2/9/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVCreateAccountViewController : INVCustomTableViewController

@property (strong, nonatomic) INVAccount *accountToEdit;
@property (assign, nonatomic) BOOL signupSuccess;

@end
