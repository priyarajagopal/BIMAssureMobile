//
//  INVFile.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVFileVersion.h"

/**
 Array of INVPackage objects
 */
typedef NSArray* INVPackageArray;
/**
 Mutable array of INVPackage objects
 */
typedef NSMutableArray* INVPackageMutableArray;

@interface INVPackage : MTLModel  <MTLJSONSerializing,MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSNumber* version;
@property (copy, nonatomic, readonly) NSNumber* tipId;
@property (copy, nonatomic, readonly) NSNumber* packageId;
@property (copy, nonatomic, readonly) NSDate* createdAt;
@property (copy, nonatomic, readonly) NSNumber* createdBy;
@property (copy, nonatomic, readonly) NSDate* updatedAt;
@property (copy, nonatomic, readonly) NSNumber* updatedBy;
@property (copy, nonatomic, readonly) NSNumber* projectId;
@property (copy, nonatomic, readonly) NSString* packageName;

@end
