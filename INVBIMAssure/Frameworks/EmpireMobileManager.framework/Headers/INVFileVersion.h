//
//  INVFileVersion.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>


/**
 Array of INVFileVersion objects
 */
typedef NSArray* INVFileVersionArray;
/**
 Mutable array of INVFileVersion objects
 */
typedef NSMutableArray* INVFileVersionMutableArray;

@interface INVFileVersion : MTLModel<MTLJSONSerializing,MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSNumber* fileVersionId;
@property (copy, nonatomic, readonly) NSNumber* version;
@property (copy, nonatomic, readonly) NSNumber* fileMasterId;
@property (copy, nonatomic, readonly) NSNumber* modelId;
@property (copy, nonatomic, readonly) NSString* dataState;
@property (copy, nonatomic, readonly) NSNumber* projectId;

@end
