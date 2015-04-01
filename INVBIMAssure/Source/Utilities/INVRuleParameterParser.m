//
//  INVRuleParameterParser.m
//  INVBIMAssure
//
//  Created by Richard Ross on 4/1/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleParameterParser.h"

#import "INVRuleInstanceTableViewController+Private.h"
#import "NSArray+INVCustomizations.h"

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
    NSArray *keys = ruleDefinition.formalParams.properties.allKeys;
    NSDictionary *entries = [NSDictionary dictionaryWithObjects:[keys arrayByApplyingBlock:^id(id key, NSUInteger _, BOOL *__) {
        INVRuleFormalParam *formalParam = ruleDefinition.formalParams;
        NSDictionary *elementDesc = (NSDictionary *) formalParam.properties[key];

        NSString *localizedDisplayName = key;
        if ([elementDesc.allKeys containsObject:@"display"]) {
            NSDictionary *displayNameDict = formalParam.properties[key][@"display"];
            NSString *currentLocale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
            if ([displayNameDict.allKeys containsObject:currentLocale]) {
                localizedDisplayName = displayNameDict[currentLocale];
            }
        }

        INVParameterType type = INVParameterTypeFromString(elementDesc[@"type"]);
        NSMutableDictionary *dictionary = [@{
            INVActualParamName : key,
            INVActualParamType : @(type),
            INVActualParamDisplayName : localizedDisplayName
        } mutableCopy];

        if (elementDesc[@"unit"]) {
            dictionary[INVActualParamUnit] = @"";
        }

        return dictionary;
    }] forKeys:keys];

    [ruleInstance.actualParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        INVRuleInstanceActualParamDictionary valueDict = (INVRuleInstanceActualParamDictionary) obj;
        NSMutableDictionary *entry = entries[key];

        entry[INVActualParamValue] = valueDict[@"value"];

        if (valueDict[@"unit"]) {
            entry[INVActualParamUnit] = valueDict[@"unit"];
        }
    }];

    return entries.allValues;
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

- (BOOL)areActualParametersValid:(NSArray *)params
                   forDefinition:(INVRule *)ruleDefinition
                    failureBlock:(void (^)(NSString *))failureBlock
{
    __block BOOL failed = NO;

    [params enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *actualDict = obj;

        id unit = actualDict[INVActualParamUnit];
        id value = actualDict[INVActualParamValue];
        INVParameterType type = [actualDict[INVActualParamType] integerValue];

        switch (type) {
            case INVParameterTypeString:
            case INVParameterTypeNumber:
                if ([unit length] && [value length] == 0) {
                    failureBlock(NSLocalizedString(@"UNIT_WITH_NO_VALUE", nil));
                    *stop = failed = YES;
                }

                break;

            case INVParameterTypeElementType:
                // TODO: Determine if element type id is correct.
                break;

            case INVParameterTypeArray:
                if (![value isKindOfClass:[NSArray class]]) {
                    failureBlock(NSLocalizedString(@"NOT_AN_ARRAY", nil));
                    *stop = failed = YES;
                    break;
                }
        }
    }];

    return !failed;
}

@end
