//
//  INVRule.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/20/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//
#import <Mantle/Mantle.h>
#import "INVRuleFormalParam.h"
#import "INVRuleDescriptor.h"

/*
 {
 "id": 418,
 "s3key": "System/Rules/RulePackages/CheckPropertyValueEqual.rule",
 "formalparams": {
 "title": "formal-parameters",
 "parameters": {
 "property_value": {
 "unit": "optional",
 "order": 3,
 "display": {
 "fr": "Propriété Valeur",
 "en": "Property Value"
 },
 "type": [
 "number",
 "date",
 "string"
 ]
 },
 "property_name": {
 "order": 2,
 "display": {
 "fr": "nom de la propriété",
 "en": "Property Name"
 },
 "type": "string"
 },
 "element_type": {
 "order": 1,
 "display": {
 "fr": "Type d' élément",
 "en": "Element Type"
 },
 "type": "batype"
 }
 },
 "type": "object"
 },
 "descriptor": {
 "resources": {
 "fr": { },
 "en": {
 "long-description": "This rule checks if all elements of a type in the model have a specified property value.",
 "name": "Check Property Value Equal",
 "issues": [
 "Element(s) without specified property value",
 "Element(s) without specified property value",
 "input parameters validation failed"
 ],
 "short-description": "Check if element property value is as specified."
 }
 },
 "vendor": "Invicara",
 "name": "CheckPropertyValueEqual",
 "version": 1
 },
 "updatedby": 31,
 "vendor": "Invicara",
 "rulename": "CheckPropertyValueEqual",
 "systemrulesid": 22,
 "createdby": 31,
 "createdat": 1429188984000,
 "updatedat": 1429188984000,
 "accountid": 32,
 "version": 1
 }
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
@property (copy, nonatomic, readonly) INVRuleDescriptor *descriptor;
@end
