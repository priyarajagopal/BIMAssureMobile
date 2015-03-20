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
 {
 "id": 6290,
 "completedat": 1426816584000,
 "results": [
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
 },
 {
 "analysisrunid": 6290,
 "ruledescription": "Check if a property exists in meta attributes",
 "status": "Completed",
 "rulename": "CheckPropertyExist",
 "runtime": 170,
 "createdby": 7,
 "createdat": 1426816583000,
 "updatedat": 1426816584000,
 "actualparams": {
 "name": "OST_Walls",
 "property": "WIDTH"
 },
 "id": 6291,
 "updatedby": 7,
 "issues": [
 {
 "id": "6297",
 "status": "Unknown",
 "description": "com.invicara.empire.rules.CheckPropertyExist has issues.",
 "name": "com.invicara.empire.rules.CheckPropertyExist",
 "errorcount": "0"
 }
 ],
 "ruleid": 6289
 }
 ],
 "updatedby": 7,
 "status": "Completed",
 "analysisid": 99,
 "createdby": 7,
 "executedat": 1426816583000,
 "createdat": 1426816583000,
 "updatedat": 1426816584000,
 "pkgversionid": 102
 }
 
 *****/

/**
 Array of INVAnalysisRunDetails objects
 */
typedef NSArray *INVAnalysisRunDetailsArray;
/**
 Mutable array of INVAnalysisRunDetails objects
 */
typedef NSMutableArray *INVAnalysisRunDetailsMutableArray;

@interface INVAnalysisRunDetails : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSNumber *analysisRunDetailsId;
@property (copy, nonatomic, readonly) NSNumber *analysisId;
@property (copy, nonatomic, readonly) NSNumber *pkgVersionId;
@property (copy, nonatomic, readonly) NSString *status;

@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSDate *completedAt;

@property (copy, nonatomic, readonly) INVAnalysisRunResultsArray runDetails;

@end
