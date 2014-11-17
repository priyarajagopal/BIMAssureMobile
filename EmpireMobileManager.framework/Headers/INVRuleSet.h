//
//  INVRuleSet.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVRuleSet objects
 */
typedef NSArray* INVRuleSetArray;
/**
 Mutable array of INVRuleSet objects
 */
typedef NSMutableArray* INVRuleSetMutableArray;

@interface INVRuleSet : MTLModel <MTLJSONSerializing,MTLManagedObjectSerializing>

@property (copy, nonatomic, readonly) NSString* name;
@property (copy, nonatomic, readonly) NSString* overview;
@property (copy, nonatomic, readonly) NSNumber* totalParamCount;
@property (copy, nonatomic, readonly) NSNumber* emptyParamCount;
@property (copy, nonatomic, readonly) NSNumber* ruleSetId;
@property (copy, nonatomic, readonly) NSNumber* projectId;
@property (copy, nonatomic, readonly) NSArray* ruleInstances;


@end
