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
typedef NSArray* INVUserArray;

/**
 Mutable array of INVUser objects
 */
typedef NSMutableArray* INVUserMutableArray;


@interface INVUser : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSString* accountType;
@property (copy, nonatomic, readonly) NSNumber* accountId;
@property (copy, nonatomic, readonly) NSString* email;
@property (copy, nonatomic, readonly) NSNumber *isAdmin;
@property (copy, nonatomic, readonly) NSString* name;
@property (copy, nonatomic, readonly) NSNumber* userId;
@end
