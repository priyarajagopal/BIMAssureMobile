//
//  INVProject.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/2/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVProject objects
 */
typedef NSArray *INVProjectArray;
/**
 Mutable array of INVProject objects
 */
typedef NSMutableArray *INVProjectMutableArray;

@interface INVProject : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSString* overview;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSNumber *projectId;
@property (copy, nonatomic, readonly) NSNumber *accountId;
@property (copy, nonatomic, readonly) NSString *name;
@end
