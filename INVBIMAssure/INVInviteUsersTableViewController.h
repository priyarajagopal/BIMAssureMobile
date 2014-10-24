//
//  INVInviteUsersTableViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/24/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomTableViewController.h"

@interface INVInviteUsersTableViewController : INVCustomTableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
- (IBAction)onSendClicked:(id)sender;

@end
