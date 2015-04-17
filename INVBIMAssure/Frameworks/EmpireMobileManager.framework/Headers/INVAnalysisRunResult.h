//
//  INVAnalysisRunResult.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/17/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVRuleInstance.h"
#import "INVRuleIssue.h"
#import "INVRuleDescriptor.h"

/*
 {
 "analysisrunid": 795,
 "ruledescription": "Check if element property exists.",
 "status": 2,
 "numelements": 4,
 "rulename": "CheckPropertyExist",
 "runtime": 232,
 "createdby": 98,
 "rulediscriptor": {
 "resources": {
 "fr": { },
 "en": {
 "long_description": "This rule checks if all elements of a type in the model have a specific property.",
 "short_description": "Check if element property exists.",
 "name": "Check Property Exist",
 "issues": [
 "Element(s) with property",
 "Element(s) without property",
 "input parameters validation failed"
 ]
 }
 },
 "vendor": "Invicara",
 "name": "CheckPropertyExist",
 "version": 1
 },
 "createdat": 1429294401000,
 "updatedat": 1429294403000,
 "actualparams": {
 "property_name": {
 "value": "door_frame"
 },
 "element_type": {
 "value": "23 17 11"
 }
 },
 "id": 796,
 "updatedby": 98,
 "issues": [
 {
 "id": 797,
 "status": 2,
 "description": 2,
 "msgparams": [ ],
 "numelements": 4,
 "name": "CheckPropertyExist"
 }
 ],
 "ruleid": 761,
 "numissues": 1
 }
 ],
 "includetotal": false,
 "offset": 0
 }
 */
 
/**
 Array of INVAnalysisRunResult objects
 */
typedef NSArray *INVAnalysisRunResultsArray;
/**
 Mutable array of INVAnalysisRunResult objects
 */
typedef NSMutableArray *INVAnalysisRunResultsMutableArray;

@interface INVAnalysisRunResult : MTLModel<MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSNumber *analysisRunId;
@property (copy, nonatomic, readonly) NSNumber *analysisRunResultId;
@property (copy, nonatomic, readonly) NSString *ruleDescription;
@property (copy, nonatomic, readonly) NSNumber *status;
@property (copy, nonatomic, readonly) NSString *ruleName;
@property (copy, nonatomic, readonly) NSNumber *ruleId;
@property (copy, nonatomic, readonly) NSNumber *runTime;


@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSNumber* numIssues;
@property (copy, nonatomic, readonly) NSNumber* numElements;
@property (copy, nonatomic, readonly) INVRuleDescriptor* ruleDescriptor;

@property (copy, nonatomic, readonly) INVRuleIssueArray issues;
@property (copy, nonatomic, readonly) INVRuleInstanceActualParamDictionary actualParameters; //  dictionary

@end
