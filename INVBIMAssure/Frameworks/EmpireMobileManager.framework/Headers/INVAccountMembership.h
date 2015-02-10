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
 Array of _INV_MEMBERSHIP_TYPE values
 */
typedef NSArray *INVRolesArray;

/**
 Mutable Array of _INV_MEMBERSHIP_TYPE values
 */
typedef NSMutableArray *INVRolesMutableArray;

typedef enum {
    INV_MEMBERSHIP_TYPE_REGULAR = 0,
    INV_MEMBERSHIP_TYPE_ADMIN = 1

} INV_MEMBERSHIP_TYPE;

/** 
 Array of possible membership types
 */

typedef NSString* INV_DISPLAY_STRING;
static const INV_DISPLAY_STRING INV_ADMIN_DISPLAYSTRING = @"Admin";
static const INV_DISPLAY_STRING INV_MEMBER_DISPLAYSTRING = @"Member";

/**
 Dictionary of <INV_MEMBERSHIP_TYPE,INV_DISPLAY_STRING> pairs
 */
typedef NSDictionary* INVMembershipTypeDictionary;

/**
 array of INVMembershipTypeDictionary objects
 */
typedef NSArray* INVMembershipTypes;

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
@property (copy, nonatomic, readonly) INVRolesArray roles; // Right now only one value, possibly two (one for xos and one for EM)
@end
