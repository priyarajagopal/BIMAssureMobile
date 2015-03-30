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
 "analysisrunid": 6290,
 "ruledescription": "Check if a property value exists",
 "status": "Completed",
 "rulename": "CheckPropertyValueExist",
 "runtime": 179,
 "createdby": 7,
 "createdat": 1426815829000,
 "updatedat": 1426816583000,
 "actualparams": {
 "name": "OST_Doors",
 "property": "DOOR_WIDTH"
 },
 "id": 6281,
 "updatedby": 7,
 "issues": [
 {
 "id": "6287",
 "status": "Unknown",
 "description": "com.invicara.empire.rules.CheckPropertyValueExist has issues.",
 "name": "com.invicara.empire.rules.CheckPropertyValueExist",
 "errorcount": "0"
 }
 ],
 "ruleid": 100
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
@property (copy, nonatomic, readonly) NSNumber *ruleDefId;
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
