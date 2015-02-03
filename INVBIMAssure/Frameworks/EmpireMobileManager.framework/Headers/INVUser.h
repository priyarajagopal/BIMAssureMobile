//
//  INVUser.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 9/30/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVUser objects
 */
typedef NSArray *INVUserArray;

/**
 Mutable array of INVUser objects
 */
typedef NSMutableArray *INVUserMutableArray;

@interface INVUser : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *firstName;
@property (copy, nonatomic, readonly) NSString *lastName;
@property (copy, nonatomic, readonly) NSString *address;
@property (copy, nonatomic, readonly) NSString *phoneNumber;
@property (copy, nonatomic, readonly) NSString *companyName;
@property (copy, nonatomic, readonly) NSString *title;
@property (copy, nonatomic, readonly) NSNumber *userId;
@property (copy, nonatomic, readonly) NSNumber *accountId;
@property (copy, nonatomic, readonly) NSNumber *allowNotifications;
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;

@end
