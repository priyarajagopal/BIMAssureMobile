//
//  INVRuleParameterParser.h
//  INVBIMAssure
//
//  Created by Richard Ross on 4/1/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVRuleParameterParser : NSObject

+ (instancetype)instance;

- (NSArray *)transformRuleInstanceParamsToArray:(id)ruleInstance definition:(INVRule *)ruleDefinition;
- (INVRuleInstanceActualParamDictionary)transformRuleInstanceArrayToRuleInstanceParams:(NSArray *)actualParamsArray;
- (BOOL)areActualParametersValid:(NSArray *)params
                   forDefinition:(INVRule *)ruleDefinition
                    failureBlock:(void (^)(NSString *))failureBlock;
@end
