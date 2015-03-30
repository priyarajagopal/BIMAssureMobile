//
//  INVRuleInstanceTableViewCell+INVRuleInstanceTableViewController_Private.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/24/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewController+Private.h"

NSString *const INVActualParamName = @"name";
NSString *const INVActualParamDisplayName = @"displayName";
NSString *const INVActualParamType = @"type";
NSString *const INVActualParamValue = @"value";
NSString *const INVActualParamUnit = @"unit";

static NSString *INVParamaterTypeStrings[] = {@"string", @"number", @"batype", @"array"};

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