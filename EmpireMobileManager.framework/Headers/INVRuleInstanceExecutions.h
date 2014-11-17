//
//  INVRuleInstanceExecutions.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 11/13/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface INVRuleInstanceExecutions : MTLModel<MTLJSONSerializing,MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly)NSArray* executions;

@end
