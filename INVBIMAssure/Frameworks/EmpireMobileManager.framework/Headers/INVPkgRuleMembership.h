//
//  INVPkgRuleMembership.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 12/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
@interface INVPkgRuleMembership : MTLModel <MTLJSONSerializing,MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSNumber* ruleSetId;
@property (copy, nonatomic, readonly) NSNumber* pkgMasterId;
@property (copy, nonatomic, readonly) NSNumber* membershipId;
@end
