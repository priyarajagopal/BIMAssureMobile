//
//  INVAnalysisRunDetails.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/20/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVAnalysisRunResult.h"

/***
 "list": [
 {
 "id": 78618,
 "completedat": 1427295076000,
 "numrule": 1,
 "updatedby": 7,
 "status": 2,
 "analysisid": 21153,
 "createdby": 7,
 "executedat": 1427295075000,
 "createdat": 1427295075000,
 "numissues": 1,
 "updatedat": 1427295076000,
 "pkgversionid": 78406
 }
 ],

 *****/



/**
 Array of INVAnalysisRunDetails objects
 */
//typedef NSArray *INVAnalysisRunDetailsArray;
/**
 Mutable array of INVAnalysisRunDetails objects
 */
//typedef NSMutableArray *INVAnalysisRunDetailsMutableArray;

@interface INVAnalysisRunDetails : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSNumber *analysisRunDetailsId;
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

@end
