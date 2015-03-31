//
//  INVBAUnit.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/27/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>


/**
 Array of INVBAUnit objects
 */
typedef NSArray *INVBAUnitArray;
/**
 Mutable array of INVUnit objects
 */
typedef NSMutableArray *INVBAUnitMutableArray;

@interface INVBAUnit : MTLModel<MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSString *display;
@property (copy, nonatomic, readonly) NSString *unit;
@property (copy, nonatomic, readonly) NSString *som;

@end
