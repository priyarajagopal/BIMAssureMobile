//
//  INVRuleDescriptor.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 4/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//
#import <Mantle/Mantle.h>
#import "INVRuleDescriptorResourceDescription.h"

@interface INVRuleDescriptor : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSString *vendor;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSNumber *version;
@property (copy, nonatomic, readonly) NSDictionary *resources;

-(INVRuleDescriptorResourceDescription*)descriptionDetailsForLanguageCode:(NSString*)details ;

@end
