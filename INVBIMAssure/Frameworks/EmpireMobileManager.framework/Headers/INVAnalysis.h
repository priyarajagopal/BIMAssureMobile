//
//  INVAnalysis.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/10/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVRuleInstance.h"
/*
 {
 "totalparamcount": 0,
 "id": 303481,
 "emptyparamcount": 0,
 "updatedby": 7,
 "description": "Compliance with energy standards",
 "name": "Energy Study",
 "projectid": 257,
 "createdby": 7,
 "createdat": 1426036974000,
 "rules":[
 ],
 "updatedat": 1426036974000
 */
/**
 Array of INVAnalysis objects
 */
typedef NSArray *INVAnalysisArray;
/**
 Mutable array of INVAnalysis objects
 */
typedef NSMutableArray *INVAnalysisMutableArray;

@interface INVAnalysis : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>

@property (copy, nonatomic, readonly) NSNumber *analysisId;
@property (copy, nonatomic, readonly) NSNumber *totalParamCount;
@property (copy, nonatomic, readonly) NSNumber *emptyParamCount;
@property (copy, nonatomic, readwrite) INVRuleInstanceArray rules;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *overview;
@property (copy, nonatomic, readonly) NSNumber *projectId;
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@end
