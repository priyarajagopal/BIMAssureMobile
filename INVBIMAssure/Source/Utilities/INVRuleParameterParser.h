//
//  INVRuleParameterParser.h
//  INVBIMAssure
//
//  Created by Richard Ross on 4/1/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Dictionary of Name-Value pairs corresponding to the actual parameters. The supported keys are  INV_ActualParamName and
 INV_ActualParamValue
 */
typedef NSMutableDictionary *INVActualParamKeyValuePair;

/** The name of the parameter */
extern NSString *const INVActualParamName;

/** The localized display name parameter, or the parameter name if a localization does not exist for this locale */
extern NSString *const INVActualParamDisplayName;

/* The types this parameter supports. Will be an array of NSNumbers corresponding to values in the INVParameterType enum. */
extern NSString *const INVActualParamType;

/** The type constraints of the types in the INVActualParamType array. */
extern NSString *const INVActualParamTypeConstraints;

/* The value of this paramter. The type of this is determined by the entires in the type parameter */
extern NSString *const INVActualParamValue;

/* The unit identifier this value is in. */
extern NSString *const INVActualParamUnit;

typedef NS_ENUM(NSUInteger, INVParameterType) {
    INVParameterTypeString,
    INVParameterTypeNumber,
    INVParameterTypeDate,

    INVParameterTypeElementType,
    INVParameterTypeRange,
};

NSString *INVParameterTypeToString(INVParameterType type);
INVParameterType INVParameterTypeFromString(NSString *type);

@interface INVRuleParameterParser : NSObject

+ (instancetype)instance;

- (NSArray *)transformRuleInstanceParamsToArray:(id)ruleInstance definition:(INVRule *)ruleDefinition;
- (INVRuleInstanceActualParamDictionary)transformRuleInstanceArrayToRuleInstanceParams:(NSArray *)actualParamsArray;
- (BOOL)isValueValid:(id)value forParameterType:(INVParameterType)type withConstraints:(NSDictionary *)constraints;

@end
