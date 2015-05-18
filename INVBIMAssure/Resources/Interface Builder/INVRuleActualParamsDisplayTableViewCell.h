//
//  INVRuleActualParamsDisplayTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 4/8/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INVRuleParameterParser.h"

@interface INVRuleActualParamsDisplayTableViewCell : UITableViewCell
@property (nonatomic, strong) INVActualParamKeyValuePair actualParamDictionary;
@property (nonatomic, copy) UIColor* textTintColor;
@end
