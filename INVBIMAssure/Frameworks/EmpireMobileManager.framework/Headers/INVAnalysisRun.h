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
 "id": 361,
 "completedat": 0,
 "updatedby": 4,
 "status": "Started",
 "analysisid": 158,
 "createdby": 4,
 "executedat": 1426781095000,
 "createdat": 1426781095000,
 "updatedat": 1426781095000,
 "pkgversionid": 84
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

@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSDate *completedAt;
@property (copy, nonatomic, readonly) NSDate *executedAt;
@end
