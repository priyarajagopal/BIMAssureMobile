//
//  INVRule.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/20/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//
#import <Mantle/Mantle.h>
#import "INVRuleFormalParam.h"
/*
 /*
 [
 {
 "id": 253,
 "s3key": "development/System/Rules/RulePackages/CheckPropertyExist.rule",
 "ruledescription": "Check if a property exists in meta attributes",
 "formalparams":{
 "title": "formal-parameters",
 "properties":{
 "name":{"type": "string"},
 "property":{"type": "string"}
 },
 "type": "object"
 },
 "updatedby": 7,
 "vendor": "",
 "systemrulesid": 3,
 "createdby": 7,
 "createdat": 1425649279000,
 "updatedat": 1425649279000,
 "accountid": 8,
 "version": 1
 },
 {
 "id": 254,
 "s3key": "development/System/Rules/RulePackages/CheckPropertyValueExist.rule",
 "ruledescription": "Check if a property value exists",
 "formalparams":{
 "title": "formal-parameters",
 "properties":{
 "name":{"type": "string"},
 "property":{"type": "string"}
 },
 "type": "object"
 },
 "updatedby": 7,
 "vendor": "",
 "systemrulesid": 4,
 "createdby": 7,
 "createdat": 1425649279000,
 "updatedat": 1425649279000,
 "accountid": 8,
 "version": 1
 }
 ]
 */

/**
 Array of INVRule objects
 */
typedef NSArray *INVRuleArray;
/**
 Mutable array of INVRule objects
 */
typedef NSMutableArray *INVRuleMutableArray;

@interface INVRule : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>

@property (copy, nonatomic, readonly) NSString *ruleName;
@property (copy, nonatomic, readonly) NSString *overview;
@property (copy, nonatomic, readonly) NSString *s3Key;
@property (copy, nonatomic, readonly) NSNumber *accountId;
@property (copy, nonatomic, readonly) NSNumber *ruleId;
@property (copy, nonatomic, readonly) NSNumber *systemRulesId;
@property (copy, nonatomic, readonly) NSNumber *version;
@property (copy, nonatomic, readonly) NSString *vendor;
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) INVRuleFormalParam *formalParams;

@end
