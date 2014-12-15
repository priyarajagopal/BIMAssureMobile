//
//  INVRuleInstanceExecution.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 11/13/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVRuleInstance.h"

/**
 Array of INVRuleInstanceExecution objects
 */
typedef NSArray* INVRuleInstanceExecutionArray;
/**
 Mutable array of INVRuleInstanceExecution objects
 */
typedef NSMutableArray* INVRuleInstanceExecutionMutableArray;

@interface INVRuleInstanceExecution : MTLModel <MTLJSONSerializing,MTLManagedObjectSerializing>

@property (copy, nonatomic, readonly) NSString* groupTag;
@property (copy, nonatomic, readonly) NSString* groupName;
@property (copy, nonatomic, readonly) NSString* overview;
@property (copy, nonatomic, readonly) NSString* status;
@property (copy, nonatomic, readonly) NSDate* executedAt;
@property (copy, nonatomic, readonly) NSNumber* pkgVersionId;
@property (copy, nonatomic, readonly) NSNumber* ruleInstanceId;
@property (copy, nonatomic, readonly) NSNumber* issueCount;
@property (copy, nonatomic, readonly) NSNumber* executionId;
@property (copy, nonatomic, readonly) NSNumber* ruleSetId;
@property (copy, nonatomic, readonly) NSNumber* accountRuleId;
@property (copy, nonatomic, readonly)NSDictionary* actualParameters;
@property (copy, nonatomic, readonly)NSArray* issues; // TODO: Define this


@end
