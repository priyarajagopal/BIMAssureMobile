//
//  INVBuildingElement.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 12/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVBuildingElement objects
 */
typedef NSArray *INVBuildingElementArray;
/**
 Mutable array of INVBuildingElement objects
 */
typedef NSMutableArray *INVBuildingElementMutableArray;

@interface INVBuildingElement : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSNumber *elementId;
@property (copy, nonatomic, readonly) NSString *guid;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *externalId;
@property (copy, nonatomic, readonly)
    NSArray *metaAttributes; // May need to define specific interfaces if it becomes relevant at front end
@property (copy, nonatomic, readonly)
    NSArray *properties; // May need to define specific interfaces if it becomes relevant at front end
@property (copy, nonatomic, readonly)
    NSArray *materials; // May need to define specific interfaces if it becomes relevant at front end
@property (copy, nonatomic, readonly)
    NSArray *relationships; // May need to define specific interfaces if it becomes relevant at front end

@end
