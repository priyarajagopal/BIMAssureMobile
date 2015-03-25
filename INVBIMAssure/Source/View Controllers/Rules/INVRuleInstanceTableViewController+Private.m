//
//  INVRuleInstanceTableViewCell+INVRuleInstanceTableViewController_Private.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/24/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewController+Private.h"

static NSString *INVParamaterTypeStrings[] = {@"string", @"number", @"batype"};
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