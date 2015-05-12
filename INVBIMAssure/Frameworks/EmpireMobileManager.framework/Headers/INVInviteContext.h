//
//  INVInviteContext.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 5/11/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface INVInviteContext : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSArray *projects;
@end
