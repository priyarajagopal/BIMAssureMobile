//
//  INVRuleInstance.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/*

{
    "ruledefid": 419,
    "emptyparamcount": 0,
    "createdby": 31,
    "createdat": 1429203688000,
    "actualparams": {
        "property_name": {
            "value": "width"
        },
        "element_type": {
            "value": "23 17 11 11 11"
        }
    },
    "updatedat": 1429207171000,
    "id": 2941,
    "paramcount": 2,
    "updatedby": 31,
    "description": "check if door frame has width property",
    "name": "CheckPropertyValueExist",
    "analysisid": 439,
    "ruledefname": "CheckPropertyValueExist"
}
*/
/**
 Array of INVRuleInstance objects
 */
typedef NSArray *INVRuleInstanceArray;
/**
 Mutable array of INVRuleInstance objects
 */
typedef NSMutableArray *INVRuleInstanceMutableArray;

/*
 Actual parameters dictionary
 */
typedef NSDictionary *INVRuleInstanceActualParamDictionary;

/*
 Actual parameters dictionary
 */
typedef NSDictionary *INVRuleInstanceActualParamMutableDictionary;

@interface INVRuleInstance : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSNumber *ruleInstanceId;
@property (copy, nonatomic, readonly) NSNumber *ruleDefId;
@property (copy, nonatomic, readonly) NSString *ruleName;
@property (copy, nonatomic, readonly) NSString *overview;
@property (copy, nonatomic, readonly) NSString *ruleDefName;
@property (copy, nonatomic, readonly) NSNumber *emptyParamCount;
@property (copy, nonatomic, readonly) NSNumber *analysisId;

@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) INVRuleInstanceActualParamDictionary actualParameters; //  dictionary

//-(instancetype) initWithRuleInstanceId:(NSNumber*)ruleInstanceId inRuleSet:(NSNumber*)ruleSetId
// withRuleId:(NSNumber*)accountRuleId ruleName:(NSString*)ruleName overview:(NSString*)overview
// actualParams:(INVRuleInstanceActualParamDictionary)actualParams;
@end
