//
//  INVMembership.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 9/30/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVUser.h"
#import "INVAccount.h"

/**
 Array of INVAccountMembership objects
 */
typedef NSArray *INVMembersArray;

/**
 Mutable array of INVAccountMembership objects
 */
typedef NSMutableArray *INVMembersMutableArray;

@interface INVAccountMembership : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSNumber *accountId;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSNumber *userId;
@property (copy, nonatomic, readonly) INVAccountArray memberships;
@end
