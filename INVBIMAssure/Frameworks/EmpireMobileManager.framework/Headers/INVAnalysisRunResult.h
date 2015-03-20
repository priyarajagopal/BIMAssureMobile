//
//  INVAnalysisRunResult.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/17/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVRuleInstance.h"

 
/**
 Array of INVAnalysisRunResult objects
 */
typedef NSArray *INVAnalysisRunResultsArray;
/**
 Mutable array of INVAnalysisRunResult objects
 */
typedef NSMutableArray *INVAnalysisRunResultsMutableArray;

@interface INVAnalysisRunResult : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSNumber *ruleInstanceId;
@property (copy, nonatomic, readonly) NSNumber *ruleDefId;
@property (copy, nonatomic, readonly) NSString *ruleName;
@property (copy, nonatomic, readonly) NSString *ruleDescription;
@property (copy, nonatomic, readonly) NSNumber *runTime;
@property (copy, nonatomic, readonly) NSString *status;
@property (copy, nonatomic, readonly) NSNumber *analysisRunId;
@property (copy, nonatomic, readonly) NSNumber *analysisRunRusultId;
@property (copy, nonatomic, readonly) NSArray *issues;

@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) INVRuleInstanceActualParamDictionary actualParameters; //  dictionary

@end
