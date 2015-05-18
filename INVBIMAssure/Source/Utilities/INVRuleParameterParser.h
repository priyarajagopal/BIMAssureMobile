//
//  INVRuleParameterParser.h
//  INVBIMAssure
//
//  Created by Richard Ross on 4/1/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Dictionary of Name-Value pairs corresponding to the actual parameters. Here's the format of the dictionary:

 {
    name: "count",
    display_name: "Count",

    type: [ @5 ],
    constraints: {
        @5: {
            from_type: [ @1 ],
            to_type: [ @1 ],
            from_constraints: {  },
            to_constraints: { },
        }
    }
    value: { from: @0, to: @0 },
    unit: null,
    error: null,
 }

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

/* The last input editing error of this cell */
extern NSString *const INVActualParamError;

typedef NS_ENUM(NSUInteger, INVParameterType) {
    INVParameterTypeString,
    INVParameterTypeNumber,
    INVParameterTypeDate,
    INVParameterTypeArray,
    INVParameterTypeElementType,
    INVParameterTypeRange
};

NSString *INVParameterTypeToString(INVParameterType type);
INVParameterType INVParameterTypeFromString(NSString *type);

@interface INVRuleParameterParser : NSObject

+ (instancetype)instance;

- (NSArray *)transformRuleInstanceParamsToArray:(id)ruleInstance definition:(INVRule *)ruleDefinition;
- (INVRuleInstanceActualParamDictionary)transformRuleInstanceArrayToRuleInstanceParams:(NSArray *)actualParamsArray;
- (NSArray *)transformActualParamDictionaryToArray:(INVRuleInstanceActualParamDictionary)actualParamsDict;

- (NSError *)isValueValid:(id)value forAnyTypeInArray:(NSArray *)types withConstraints:(NSDictionary *)constraints;
- (NSError *)isValueValid:(id)value forParameterType:(INVParameterType)type withConstraints:(NSDictionary *)constraints;

- (NSArray *)orderFormalParamsInArray:(NSArray *)inputformalParams;
@end
