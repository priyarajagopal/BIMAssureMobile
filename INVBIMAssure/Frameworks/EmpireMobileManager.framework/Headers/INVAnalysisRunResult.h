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

/*
 {
 "analysisrunid": 3017,
 "ruledescription": "check if door frame has width property",
 "status": 2,
 "numelements": 0,
 "rulename": "CheckPropertyValueExist",
 "runtime": 206,
 "createdby": 31,
 "createdat": 1429214225000,
 "updatedat": 1429214226000,
 "actualparams": {
 "property_name": {
 "value": "width"
 },
 "element_type": {
 "value": "23 17 11 11 11"
 }
 },
 "id": 3018,
 "updatedby": 31,
 "issues": [
 {
 "id": 3020,
 "status": 1,
 "description": 1,
 "numelements": 0,
 "name": "CheckPropertyValueExist"
 }
 ],
 "ruleid": 2941,
 "numissues": 1
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
@property (copy, nonatomic, readonly) NSNumber *analysisRunResultId;
@property (copy, nonatomic, readonly) NSString *ruleDescription;
@property (copy, nonatomic, readonly) NSNumber *status;
@property (copy, nonatomic, readonly) NSString *ruleName;
@property (copy, nonatomic, readonly) NSNumber *ruleId;
@property (copy, nonatomic, readonly) NSNumber *runTime;

@property (copy, nonatomic, readonly) NSNumber *analysisRunId;

@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSNumber* numIssues;
@property (copy, nonatomic, readonly) INVRuleIssueArray issues;
@property (copy, nonatomic, readonly) INVRuleInstanceActualParamDictionary actualParameters; //  dictionary

@end
