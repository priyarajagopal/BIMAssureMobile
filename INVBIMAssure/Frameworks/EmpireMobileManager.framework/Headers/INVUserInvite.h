//
//  INVUserInvite.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/15/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVInvite.h"

/**
 Array of INVUserInvite objects
 */
typedef NSArray *INVUserInviteArray;

/**
 Mutable array of INVUserInvite objects
 */
typedef NSMutableArray *INVUserInviteMutableArray;

@interface INVUserInvite : INVInvite
@property (copy, nonatomic, readonly) NSString *accountName;
@property (copy, nonatomic, readonly) NSString *inviterEmail;
@end
