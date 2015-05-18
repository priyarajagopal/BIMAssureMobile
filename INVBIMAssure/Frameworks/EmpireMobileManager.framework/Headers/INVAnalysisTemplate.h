//
//  INVAnalysisTemplate.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 5/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 Array of INVAnalysisTemplate objects
 */
typedef NSArray *INVAnalysisTemplateArray;
/**
 Mutable array of INVAnalysisTemplate objects
 */
typedef NSMutableArray *INVAnalysisTemplateMutableArray;


@interface INVAnalysisTemplate : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSNumber *analysisTemplateId;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *overview;
@property (copy, nonatomic, readonly) NSNumber *accountId;
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@end
