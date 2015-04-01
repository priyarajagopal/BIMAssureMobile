//
//  INVRuleParameterParser.m
//  INVBIMAssure
//
//  Created by Richard Ross on 4/1/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleParameterParser.h"

#import "NSArray+INVCustomizations.h"

NSString *const INVActualParamName = @"name";
NSString *const INVActualParamDisplayName = @"display_name";
NSString *const INVActualParamType = @"type";
NSString *const INVActualParamTypeConstraints = @"type_constraints";
NSString *const INVActualParamValue = @"value";
NSString *const INVActualParamUnit = @"unit";

static NSString *INVParamaterTypeStrings[] = {@"string", @"number", @"date", @"batype", @"range"};
static size_t INVParamaterTypeStringsCount = sizeof(INVParamaterTypeStrings) / sizeof(*INVParamaterTypeStrings);

NSString *INVParameterTypeToString(INVParameterType type)
{
    if (__builtin_expect(type < INVParamaterTypeStringsCount, 1) == 1)
        return INVParamaterTypeStrings[type];

    return nil;
}

INVParameterType INVParameterTypeFromString(NSString *type)
{
    for (off_t index = 0; index < INVParamaterTypeStringsCount; index++) {
        if ([INVParamaterTypeStrings[index] isEqual:type]) {
            return (INVParameterType) index;
        }
    }

    return INVParameterTypeString;
}

NSArray *convertRuleDefinitionTypesToActualParamTypes(id types)
{
    if ([types isKindOfClass:[NSString class]]) {
        return @[ @(INVParameterTypeFromString(types)) ];
    }

    return [types arrayByApplyingBlock:^id(id type, NSUInteger _, BOOL *__) {
        return @(INVParameterTypeFromString(type));
    }];
}

@implementation INVRuleParameterParser

+ (id)instance
{
    static INVRuleParameterParser *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [INVRuleParameterParser new];
    });

    return instance;
}

- (NSArray *)transformRuleInstanceParamsToArray:(INVRuleInstance *)ruleInstance definition:(INVRule *)ruleDefinition
{
    NSArray *formalParamNames = ruleDefinition.formalParams.properties.allKeys;
    NSArray *formalParamValues = [formalParamNames arrayByApplyingBlock:^id(id paramName, NSUInteger _, BOOL *__) {
        NSMutableDictionary *results = [@{
            INVActualParamName : paramName,
            INVActualParamDisplayName : [NSNull null],

            INVActualParamType : [NSMutableArray new],
            INVActualParamTypeConstraints : [NSMutableDictionary new],

            INVActualParamValue : [NSNull null],
        } mutableCopy];

        NSDictionary *formalParameterProperties = ruleDefinition.formalParams.properties[paramName];

        NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        results[INVActualParamDisplayName] = formalParameterProperties[@"display"][languageCode] ?: paramName;

        if (formalParameterProperties[@"unit"]) {
            results[INVActualParamUnit] = [NSNull null];
        }

        return results;
    }];

    NSDictionary *actualParameters = [NSDictionary dictionaryWithObjects:formalParamValues forKeys:formalParamNames];

    [ruleInstance.actualParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        INVRuleInstanceActualParamDictionary valueDict = (INVRuleInstanceActualParamDictionary) obj;
        NSMutableDictionary *actualParam = actualParameters[key];

        actualParam[INVActualParamValue] = valueDict[@"value"];

        if (valueDict[@"unit"]) {
            actualParam[INVActualParamUnit] = valueDict[@"unit"];
        }
    }];

    return formalParamValues;
}

- (INVRuleInstanceActualParamDictionary)transformRuleInstanceArrayToRuleInstanceParams:(NSArray *)actualParamsArray
{
    NSMutableDictionary *actualParam = [[NSMutableDictionary alloc] initWithCapacity:0];

    [actualParamsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *actualDict = obj;
        NSString *key = actualDict[INVActualParamName];
        NSString *value = actualDict[INVActualParamValue];
        NSString *unit = actualDict[INVActualParamUnit];

        if (unit && value) {
            [actualParam setObject:@{ INVActualParamValue : value, INVActualParamUnit : unit } forKey:key];
        }
        else if (value) {
            [actualParam setObject:@{ INVActualParamValue : value } forKey:key];
        }
    }];

    return actualParam;
}

- (BOOL)isValueValid:(id)value forParameterType:(INVParameterType)type withConstraints:(NSDictionary *)constraints
{
    switch (type) {
        case INVParameterTypeString: {
            // First, type checking
            if (![value isKindOfClass:[NSString class]])
                return NO;

            // Constraint checking
            NSString *regex = constraints[@(type)][@"matches"];
            if (regex) {
                NSRange matchRange = [value rangeOfString:regex options:NSRegularExpressionSearch];
                if (matchRange.location != 0 || matchRange.length != [value length]) {
                    return NO;
                }
            }

            return YES;
        }
        case INVParameterTypeNumber: {
            if (![value isKindOfClass:[NSNumber class]])
                return NO;

            // TODO: Constraint checking

            return YES;
        }
    }

    return NO;
}

@end
