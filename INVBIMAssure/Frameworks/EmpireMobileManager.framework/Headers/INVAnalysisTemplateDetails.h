//
//  INVAnalysisTemplateDetails.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 5/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVAnalysisTemplateRecipe.h"
#import "INVRuleDescriptorResourceDescription.h"
/**
 Array of INVAnalysisTemplateDetails objects
 */
typedef NSArray *INVAnalysisTemplateDetailsArray;
/**
 Mutable array of INVAnalysisTemplateDetails objects
 */
typedef NSMutableArray *INVAnalysisTemplateDetailsMutableArray;

@interface INVAnalysisTemplateDetails : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSString *version;
@property (copy, nonatomic, readonly) NSNumber *analysisTemplateId;

@property (copy, nonatomic, readonly) NSArray* tags;
@property (copy, nonatomic, readonly) INVAnalysisTemplateRecipeArray recipes;
@property (copy, nonatomic, readonly) NSDictionary *resources;

-(INVRuleDescriptorResourceDescription*)descriptionDetailsForLanguageCode:(NSString*)details ;



@end
