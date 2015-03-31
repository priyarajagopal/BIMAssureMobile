//
//  INVInvite.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/15/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVInvite objects
 */
typedef NSArray *INVInviteArray;

/**
 Mutable array of INVInvite objects
 */
typedef NSMutableArray *INVInviteMutableArray;

@interface INVInvite : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *invitationCode;
@property (copy, nonatomic, readonly) NSNumber *invitationId;
@property (copy, nonatomic, readonly) NSArray *roles;
@end
