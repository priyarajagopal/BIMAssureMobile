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
NSString *const INVActualParamError = @"error";
NSString *const INVActualParamOrder = @"order";

static NSString *const INV_TYPEVALIDATION_DOMAIN = @"INVRuleParameterValidation";
static NSInteger const INV_TYPEVALIDATION_ERROR = 5001;

static NSString *INVParamaterTypeStrings[] = {@"string", @"number", @"date", @"array", @"batype", @"range"};
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
/*
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

        results[INVActualParamOrder] = formalParameterProperties[@"order"];
        [results[INVActualParamType]
            addObjectsFromArray:convertRuleDefinitionTypesToActualParamTypes(formalParameterProperties[@"type"])];

        NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        results[INVActualParamDisplayName] = formalParameterProperties[@"display"][languageCode] ?: paramName;

        if (formalParameterProperties[@"unit"]) {
            results[INVActualParamUnit] = [NSNull null];
        }

        if ([results[INVActualParamType] containsObject:@(INVParameterTypeRange)]) {
            NSMutableDictionary *constraints = [NSMutableDictionary new];

            constraints[@"from_type"] =
                convertRuleDefinitionTypesToActualParamTypes(formalParameterProperties[@"from"][@"type"]);
            constraints[@"to_type"] = convertRuleDefinitionTypesToActualParamTypes(formalParameterProperties[@"to"][@"type"]);

            constraints[@"from_display"] = formalParameterProperties[@"from"][@"display"][languageCode];
            constraints[@"to_display"] = formalParameterProperties[@"to"][@"display"][languageCode];

            // TODO: Fill in with range-specific constraints
            constraints[@"from_constraints"] = [NSMutableDictionary new];
            constraints[@"to_constraints"] = [NSMutableDictionary new];

            NSMutableDictionary *value = [NSMutableDictionary new];

            value[@"from"] = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"value"];
            value[@"to"] = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"value"];

            if (formalParameterProperties[@"from"][@"unit"]) {
                value[@"from"][@"unit"] = [NSNull null];
            }

            if (formalParameterProperties[@"to"][@"unit"]) {
                value[@"to"][@"unit"] = [NSNull null];
            }

            results[INVActualParamTypeConstraints][@(INVParameterTypeRange)] = constraints;
        }

        return results;
    }];

    NSDictionary *actualParameters = [NSDictionary dictionaryWithObjects:formalParamValues forKeys:formalParamNames];

    [ruleInstance.actualParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        INVRuleInstanceActualParamMutableDictionary valueDict = [(INVRuleInstanceActualParamDictionary) obj mutableCopy];
        NSMutableDictionary *actualParam = actualParameters[key];

        if ([valueDict[@"value"] isKindOfClass:[NSDictionary class]]) {
            actualParam[INVActualParamValue] = [valueDict[@"value"] mutableCopy];

            if ([((NSMutableDictionary *) valueDict[@"value"]).allKeys containsObject:@"from"]) {
                actualParam[INVActualParamValue][@"from"] = [NSMutableDictionary new];
                actualParam[INVActualParamValue][@"from"] = [valueDict[@"value"][@"from"] mutableCopy];
            }
            if ([((NSMutableDictionary *) valueDict[@"value"]).allKeys containsObject:@"to"]) {
                actualParam[INVActualParamValue][@"to"] = [NSMutableDictionary new];
                actualParam[INVActualParamValue][@"to"] = [valueDict[@"value"][@"to"] mutableCopy];
            }
        }
        else {
            actualParam[INVActualParamValue] = valueDict[@"value"];
        }

        if (valueDict[@"unit"]) {
            actualParam[INVActualParamUnit] = valueDict[@"unit"];
        }
    }];

    return formalParamValues;
}
 */

- (NSArray *)transformActualParamsToDisplayArray:(INVRuleInstanceActualParamDictionary )actualParamsDict definition:(INVRule *)ruleDefinition
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
        
        results[INVActualParamOrder] = formalParameterProperties[@"order"];
        [results[INVActualParamType]
         addObjectsFromArray:convertRuleDefinitionTypesToActualParamTypes(formalParameterProperties[@"type"])];
        
        NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        results[INVActualParamDisplayName] = formalParameterProperties[@"display"][languageCode] ?: paramName;
        
        if (formalParameterProperties[@"unit"]) {
            results[INVActualParamUnit] = [NSNull null];
        }
        
        if ([results[INVActualParamType] containsObject:@(INVParameterTypeRange)]) {
            NSMutableDictionary *constraints = [NSMutableDictionary new];
            
            constraints[@"from_type"] =
            convertRuleDefinitionTypesToActualParamTypes(formalParameterProperties[@"from"][@"type"]);
            constraints[@"to_type"] = convertRuleDefinitionTypesToActualParamTypes(formalParameterProperties[@"to"][@"type"]);
            
            constraints[@"from_display"] = formalParameterProperties[@"from"][@"display"][languageCode];
            constraints[@"to_display"] = formalParameterProperties[@"to"][@"display"][languageCode];
            
            // TODO: Fill in with range-specific constraints
            constraints[@"from_constraints"] = [NSMutableDictionary new];
            constraints[@"to_constraints"] = [NSMutableDictionary new];
            
            NSMutableDictionary *value = [NSMutableDictionary new];
            
            value[@"from"] = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"value"];
            value[@"to"] = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"value"];
            
            if (formalParameterProperties[@"from"][@"unit"]) {
                value[@"from"][@"unit"] = [NSNull null];
            }
            
            if (formalParameterProperties[@"to"][@"unit"]) {
                value[@"to"][@"unit"] = [NSNull null];
            }
            
            results[INVActualParamTypeConstraints][@(INVParameterTypeRange)] = constraints;
        }
        
        return results;
    }];
    
    NSDictionary *actualParameters = [NSDictionary dictionaryWithObjects:formalParamValues forKeys:formalParamNames];
    
    [actualParamsDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        INVRuleInstanceActualParamMutableDictionary valueDict = [(INVRuleInstanceActualParamDictionary) obj mutableCopy];
        NSMutableDictionary *actualParam = actualParameters[key];
        
        if ([valueDict[@"value"] isKindOfClass:[NSDictionary class]]) {
            actualParam[INVActualParamValue] = [valueDict[@"value"] mutableCopy];
            
            if ([((NSMutableDictionary *) valueDict[@"value"]).allKeys containsObject:@"from"]) {
                actualParam[INVActualParamValue][@"from"] = [NSMutableDictionary new];
                actualParam[INVActualParamValue][@"from"] = [valueDict[@"value"][@"from"] mutableCopy];
            }
            if ([((NSMutableDictionary *) valueDict[@"value"]).allKeys containsObject:@"to"]) {
                actualParam[INVActualParamValue][@"to"] = [NSMutableDictionary new];
                actualParam[INVActualParamValue][@"to"] = [valueDict[@"value"][@"to"] mutableCopy];
            }
        }
        else {
            actualParam[INVActualParamValue] = valueDict[@"value"];
        }
        
        if (valueDict[@"unit"]) {
            actualParam[INVActualParamUnit] = valueDict[@"unit"];
        }
    }];
    
    return formalParamValues;
}



- (NSArray *)transformActualParamDictionaryToArray:(INVRuleInstanceActualParamDictionary )actualParamsDict
{
    
    NSArray *actualParamNames = actualParamsDict.allKeys;
    NSArray *actualParamValues = [actualParamNames arrayByApplyingBlock:^id(id paramName, NSUInteger _, BOOL *__) {
        NSMutableDictionary *results = [@{
                                          INVActualParamName : paramName,
                                          INVActualParamDisplayName : paramName,
                                          INVActualParamDisplayName : [NSNull null],
                                          
                                          INVActualParamType : [NSMutableArray new],
                                          INVActualParamTypeConstraints : [NSMutableDictionary new],
                                          
                                          INVActualParamValue : [NSNull null],
                                          } mutableCopy];
        
        
        
        
        NSDictionary *actualParameterValueDict = actualParamsDict[paramName];
        results[INVActualParamValue] = actualParameterValueDict[@"value"];
        
        return results;
    }];
    
    return actualParamValues;
}

- (INVRuleInstanceActualParamDictionary)transformRuleInstanceArrayToRuleInstanceParams:(NSArray *)actualParamsArray
{
    NSMutableDictionary *actualParam = [[NSMutableDictionary alloc] initWithCapacity:0];

    [actualParamsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *actualDict = obj;
        NSString *key = actualDict[INVActualParamName];
        id value = actualDict[INVActualParamValue];
        NSString *unit = actualDict[INVActualParamUnit];

        if ([value isKindOfClass:[NSDate class]]) {
            static NSDateFormatter *dateFormatter;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dateFormatter = [NSDateFormatter new];
                [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
            });
            value = [dateFormatter stringFromDate:value];
        }

        if (unit && value) {
            [actualParam setObject:@{ INVActualParamValue : value, INVActualParamUnit : unit } forKey:key];
        }
        else if (value) {
            [actualParam setObject:@{ INVActualParamValue : value } forKey:key];
        }
    }];

    return actualParam;
}

- (NSError *)isValueValid:(id)value forAnyTypeInArray:(NSArray *)types withConstraints:(NSDictionary *)constraints
{
    for (id type in types) {
        if ([type isKindOfClass:[NSNumber class]]) {
            return [self isValueValid:value forParameterType:[type integerValue] withConstraints:constraints];
        }
        NSError *error;
        if ([type isKindOfClass:[NSArray class]]) {
            if ([value isKindOfClass:[NSArray class]]) {
                BOOL matches = YES;
                for (id element in value) {
                    error = [self isValueValid:element forAnyTypeInArray:type withConstraints:constraints];
                    if (!error) {
                        matches = NO;
                        break;
                    }
                }

                if (matches)
                    return error;
            }
        }
    }

    return nil;
}

- (NSError *)isValueValid:(id)value forParameterType:(INVParameterType)type withConstraints:(NSDictionary *)constraints
{
#warning TODO LOCALIZE THE ERROR STRINGS
    switch (type) {
        case INVParameterTypeString: {
            // First, type checking
            if (![value isKindOfClass:[NSString class]])
                return [self validationErrorObjectWithMessage:NSLocalizedString(@"Enter valid string", nil)];

            // Constraint checking
            NSString *regex = constraints[@(type)][@"matches"];
            if (regex) {
                NSRange matchRange = [value rangeOfString:regex options:NSRegularExpressionSearch];
                if (matchRange.location != 0 || matchRange.length != [value length]) {
                    return [self validationErrorObjectWithMessage:NSLocalizedString(@"Enter string matching regex", nil)];
                }
            }

            return nil;
        }
        case INVParameterTypeNumber: {
            if ([value isKindOfClass:[NSNumber class]])
                return nil;

            if ([value isKindOfClass:[NSString class]]) {
                if ([value length] == 0)
                    return nil;

                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                if (![formatter numberFromString:value]) {
                    return [self validationErrorObjectWithMessage:NSLocalizedString(@"Enter valid number", nil)];
                }
            }

            return nil;
        }
        case INVParameterTypeDate: {
            if (![value isKindOfClass:[NSDate class]])
                return [self validationErrorObjectWithMessage:NSLocalizedString(@"Enter valid date", nil)];

            return nil;
        }
        case INVParameterTypeElementType: {
            if (![value isKindOfClass:[NSString class]])
                return [self validationErrorObjectWithMessage:NSLocalizedString(@"Not a valid BA Type", nil)];

            // TODO: Check if BAType exists? (May not even be needed as we only allow selection)
            return nil;
        }
        case INVParameterTypeRange: {
            if (![value isKindOfClass:[NSDictionary class]])
                return [self validationErrorObjectWithMessage:NSLocalizedString(@"Not a valid range", nil)];

            id fromValue = value[@"from"][@"value"];
            id toValue = value[@"to"][@"value"];

            NSArray *fromTypes = constraints[@(type)][@"from_type"];
            NSArray *toTypes = constraints[@(type)][@"to_type"];

            NSDictionary *fromConstraints = constraints[@(type)][@"from_constraints"];
            NSDictionary *toConstraints = constraints[@(type)][@"to_constraints"];

            NSError *error = [self isValueValid:fromValue forAnyTypeInArray:fromTypes withConstraints:fromConstraints];
            if (error)
                return error;

            error = [self isValueValid:toValue forAnyTypeInArray:toTypes withConstraints:toConstraints];

            return error;
        }
    }

    return NO;
}

#pragma mark - helper
- (NSError *)validationErrorObjectWithMessage:(NSString *)message
{
    if (!message) {
        return nil;
    }
    return [[NSError alloc] initWithDomain:INV_TYPEVALIDATION_DOMAIN
                                      code:INV_TYPEVALIDATION_ERROR
                                  userInfo:@{NSLocalizedDescriptionKey : message}];
}

- (NSArray *)orderFormalParamsInArray:(NSArray *)inputformalParams
{
    return [inputformalParams sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *formalParam1 = obj1;
        NSDictionary *formalParam2 = obj2;
        NSInteger formalParamOrder1 = [[formalParam1 objectForKey:INVActualParamOrder] integerValue];
        NSInteger formalParamOrder2 = [[formalParam2 objectForKey:INVActualParamOrder] integerValue];

        if (formalParamOrder1 > formalParamOrder2)
            return NSOrderedDescending;
        if (formalParamOrder1 < formalParamOrder2)
            return NSOrderedAscending;
        return NSOrderedSame;

    }];
}

@end
