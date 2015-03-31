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
 "id": 555043,
 "ruledefid": 253,
 "emptyparamcount": 0,
 "updatedby": 7,
 "description": "Check if a property exists in meta attributes",
 "name": "CheckPropertyExist",
 "analysisid": 303481,
 "ruledefname": "CheckPropertyExist",
 "createdby": 7,
 "createdat": 1426280111000,
 "actualparams":{
 "name": "OST_Doors",
 "property": "DOOR_FRAME"
 },
 "updatedat": 1426280111000
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
