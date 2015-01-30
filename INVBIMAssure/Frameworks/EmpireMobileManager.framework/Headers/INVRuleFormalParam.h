//
//  INVRuleFormalParam.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/20/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface INVRuleFormalParam : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>

@property (copy, nonatomic, readonly) NSString *title;
@property (copy, nonatomic, readonly) NSString *type;
@property (copy, nonatomic, readonly) NSDictionary *properties;

@end
