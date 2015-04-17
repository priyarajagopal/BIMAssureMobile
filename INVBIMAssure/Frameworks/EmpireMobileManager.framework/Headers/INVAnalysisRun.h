//
//  INVAnalysisRun.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//


#import <Mantle/Mantle.h>

/**
 Array of INVAnalysisRun objects
 */
typedef NSArray *INVAnalysisRunArray;
/**
 Mutable array of INVAnalysisRun objects
 */
typedef NSMutableArray *INVAnalysisRunMutableArray;

/*
 "list": [
 {
 "id": 799,
 "completedat": 1429298364000,
 "numrule": 2,
 "updatedby": 98,
 "status": 2,
 "numelements": 8,
 "analysisid": 758,
 "createdby": 98,
 "executedat": 1429298363000,
 "createdat": 1429298363000,
 "numissues": 2,
 "updatedat": 1429298364000,
 "pkgversionid": 756
 }
 ],
 */

typedef NS_ENUM(NSInteger, INV_ANALYSISRUN_TYPE) {
    INV_ANALYSISRUN_TYPE_STARTED = 1,
    INV_ANALYSISRUN_TYPE_COMPLETED = 2,
    INV_ANALYSISRUN_TYPE_FAILED = 3,
    INV_ANALYSISRUN_TYPE_UNKNOWN
    
};

/**
 Array of possible membership types
 */

typedef NSString *INV_DISPLAY_STRING;
static const INV_DISPLAY_STRING INV_STARTED_DISPLAYSTRING = @"Started";
static const INV_DISPLAY_STRING INV_COMPLETED_DISPLAYSTRING = @"Completed";
static const INV_DISPLAY_STRING INV_FAILED_DISPLAYSTRING = @"Failed";
static const INV_DISPLAY_STRING INV_UNAVAILABLE_DISPLAYSTRING = @"Unavailable";

/**
 Dictionary of <INV_ANALYSISRUN_TYPE,INV_DISPLAY_STRING> pairs
 */
typedef NSDictionary *INVANalysisRunStatusDictionary;


@interface INVAnalysisRun : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSNumber *analysisRunId;
@property (copy, nonatomic, readonly) NSNumber *analysisId;
@property (copy, nonatomic, readonly) NSNumber *pkgVersionId;
@property (copy, nonatomic, readonly) NSNumber *status;
@property (copy, nonatomic, readonly) NSNumber *numIssues;
@property (copy, nonatomic, readonly) NSNumber *numRules;
@property (copy, nonatomic, readonly) NSNumber *numElements;
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSDate *completedAt;
@property (copy, nonatomic, readonly) NSDate *executedAt;
@end
