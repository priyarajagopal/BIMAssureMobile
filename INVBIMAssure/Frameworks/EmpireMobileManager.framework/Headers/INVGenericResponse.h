//
//  INVGenericSuccessObject.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 11/5/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface INVGenericResponse : MTLModel<MTLJSONSerializing,MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) id response;
@end
