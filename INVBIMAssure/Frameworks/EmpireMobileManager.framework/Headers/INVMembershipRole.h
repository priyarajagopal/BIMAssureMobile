//
//  INVMembershipRole.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 6/4/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVMembershipRole objects
 */
typedef NSArray *INVMembershipRoleArray;

/**
 Mutable Array of INVMembershipRole objects
 */
typedef NSMutableArray *INVMembershipRoleMutableArray;

@interface INVMembershipRole : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSNumber *roleId;
@property (copy, nonatomic, readonly) NSDictionary *descriptor;
@end
