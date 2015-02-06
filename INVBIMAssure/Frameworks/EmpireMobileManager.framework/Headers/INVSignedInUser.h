//
//  INVSignedInUser.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVUser.h"

@interface INVSignedInUser : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *firstName;
@property (copy, nonatomic, readonly) NSString *lastName;
@property (copy, nonatomic, readonly) NSString *accountGuid;
@property (copy, nonatomic, readonly) NSNumber* accountId;
@property (copy, nonatomic, readonly) NSArray* context;
@property (copy, nonatomic, readonly) NSString* accountType;
@property (copy, nonatomic, readonly) NSArray* roles;
@property (copy, nonatomic, readonly) NSNumber *userId;
@property (copy, nonatomic, readonly) NSString* expires;

@end
