//
//  INVAnalysisRun.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "MTLModel.h"
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
@interface INVAnalysisRun : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSNumber *analysisRunId;
@property (copy, nonatomic, readonly) NSNumber *analysisId;
@property (copy, nonatomic, readonly) NSString *status;

@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSNumber *pkgVersionId;

@end
