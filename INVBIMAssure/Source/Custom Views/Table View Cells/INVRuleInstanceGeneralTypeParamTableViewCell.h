//
//  INVRuleInstanceGeneralTypeParamTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INVRuleInstanceTableViewController+Private.h"


@class INVRuleInstanceGeneralTypeParamTableViewCell;

@protocol INVRuleInstanceGeneralTypeParamTableViewCellDelegate<NSObject>

@optional
- (void)onValidationFailed:(INVRuleInstanceGeneralTypeParamTableViewCell *)sender;
@end

@interface INVRuleInstanceGeneralTypeParamTableViewCell : UITableViewCell
@property (weak, nonatomic) id<INVRuleInstanceGeneralTypeParamTableViewCellDelegate> delegate;
@property (nonatomic, copy) INVActualParamKeyValuePair actualParamDictionary;

@end
