//
//  INVAccount.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 9/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVAccount objects
 */
typedef NSArray *INVAccountArray;
/**
 Mutable array of INVAccount objects
 */
typedef NSMutableArray *INVAccountMutableArray;

@interface INVAccount : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>

@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSNumber *accountId;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *overview;
@property (copy, nonatomic, readonly) NSString *typeVal;
@property (nonatomic, readonly) NSNumber *disabled;

@end
