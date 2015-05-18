//
//  INVAnalysisTemplateRecipe.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 5/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVRuleInstance.h"

/**
 Array of INVAnalysisTemplateRecipe objects
 */
typedef NSArray *INVAnalysisTemplateRecipeArray;
/**
 Mutable array of INVAnalysisTemplateRecipe objects
 */
typedef NSMutableArray *INVAnalysisTemplateRecipeMutableArray;


@interface INVAnalysisTemplateRecipe : MTLModel<MTLJSONSerializing>
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *overview;
@property (copy, nonatomic, readonly) INVRuleInstanceActualParamDictionary actualParameters; //  dictionary *overview;
@property (copy, nonatomic, readonly) NSNumber *ruleDefinitionId;
@end
