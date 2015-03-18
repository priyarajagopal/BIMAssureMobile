//
//  INVAnalysisPkgMembership.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVAnalysisPkgMembership objects
 */
typedef NSArray *INVAnalysisPkgMembershipArray;
/**
 Mutable array of INVAnalysisPkgMembership objects
 */
typedef NSMutableArray *INVAnalysisPkgMembershipMutableArray;


@interface INVAnalysisPkgMembership : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSNumber *analysisId;
@property (copy, nonatomic, readonly) NSNumber *pkgMasterId;
@property (copy, nonatomic, readonly) NSNumber *membershipId;
@property (copy, nonatomic, readonly) NSNumber* enabled;
@end
