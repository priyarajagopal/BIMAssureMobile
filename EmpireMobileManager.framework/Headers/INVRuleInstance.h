//
//  INVRuleInstance.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVRuleInstance objects
 */
typedef NSArray* INVINVRuleInstanceArray;
/**
 Mutable array of INVRuleInstance objects
 */
typedef NSMutableArray* INVINVRuleInstanceMutableArray;

@interface INVRuleInstance : MTLModel <MTLJSONSerializing,MTLManagedObjectSerializing>

@property (copy, nonatomic, readonly) NSString* ruleName;
@property (copy, nonatomic, readonly) NSString* overview;
@property (copy, nonatomic, readonly) NSNumber* emptyParamCount;
@property (copy, nonatomic, readonly) NSNumber* ruleSetId;
@property (copy, nonatomic, readonly) NSNumber* accountRuleId;
@property (copy, nonatomic, readonly) NSNumber* ruleInstanceId;
@property (copy, nonatomic, readonly) id actualParameters; // it can be an array or dictionary

@end
