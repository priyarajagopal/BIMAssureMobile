//
//  INVRuleInstanceTableViewCell+INVRuleInstanceTableViewController_Private.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/24/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVRuleInstanceTableViewController.h"

/**
 Dictionary of Name-Value pairs corresponding to the actual parameters. The supported keys are  INV_ActualParamName and
 INV_ActualParamValue
 */
typedef NSMutableDictionary *INVActualParamKeyValuePair;


extern NSString *const INVActualParamName;
extern NSString *const INVActualParamType;
extern NSString *const INVActualParamValue;

typedef NS_ENUM(NSUInteger, INVParameterType) {
    INVParameterTypeString,
    INVParameterTypeNumber,
    INVParameterTypeElementType,
};

NSString *INVParameterTypeToString(INVParameterType type);
INVParameterType INVParameterTypeFromString(NSString *type);