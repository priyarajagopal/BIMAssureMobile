//
//  INVRule.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/20/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//
#import <Mantle/Mantle.h>
#import "INVRuleFormalParam.h"

/**
 Array of INVRule objects
 */
typedef NSArray* INVRuleArray;
/**
 Mutable array of INVRule objects
 */
typedef NSMutableArray* INVRuleMutableArray;

@interface INVRule : MTLModel <MTLJSONSerializing,MTLManagedObjectSerializing>

@property (copy, nonatomic, readonly) NSString* ruleName;
@property (copy, nonatomic, readonly) NSString* overview;
@property (copy, nonatomic, readonly) NSNumber* accountId;
@property (copy, nonatomic, readonly) NSNumber* ruleId;
@property (copy, nonatomic, readonly) NSNumber* version;
@property (copy, nonatomic, readonly) INVRuleFormalParam* formalParams;

@end
