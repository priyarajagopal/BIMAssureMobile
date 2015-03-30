//
//  INVRuleIssue.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/25/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
/*
 {
 "totalcount": 0,
 "pagesize": 1000,
 "list": [
 {
 "id": "78620",
 "status": "0",
 "description": "com.invicara.empire.rules.CheckPropertyValueExist has issues.",
 "name": "com.invicara.empire.rules.CheckPropertyValueExist",
 "errorcount": "0"
 }
 ],
 "includetotal": false,
 "offset": 0
 }

 */
/**
 Array of INVRuleIssue objects
 */
typedef NSArray *INVRuleIssueArray;
/**
 Mutable array of INVRuleIssue objects
 */
typedef NSMutableArray *INVRuleIssueMutableArray;

@interface INVRuleIssue : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSNumber *issueId;
@property (copy, nonatomic, readonly) NSString *issueDescription;
@property (copy, nonatomic, readonly) NSString *issueName;
@property (copy, nonatomic, readonly) NSNumber *errorCount;
@property (copy, nonatomic, readonly) NSNumber *status;
@end
