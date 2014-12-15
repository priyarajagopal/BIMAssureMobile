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
 Array of INVFile objects
 */
typedef NSArray* INVFileArray;
/**
 Mutable array of INVFile objects
 */
typedef NSMutableArray* INVFileMutableArray;

@interface INVFile : MTLModel  <MTLJSONSerializing,MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSNumber* version;
@property (copy, nonatomic, readonly) NSNumber* tipId;
@property (copy, nonatomic, readonly) NSNumber* fileId;
@property (copy, nonatomic, readonly) NSNumber* accountId;
@property (copy, nonatomic, readonly) NSString* fileName;
@property (copy, nonatomic, readonly) INVFileVersionArray fileVersions;
@end
