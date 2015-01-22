//
//  INVGenericSuccessObject.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 11/5/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface INVGenericSuccess : MTLModel <MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSString *message;
@property (copy, nonatomic, readonly) NSNumber *code;
@end
