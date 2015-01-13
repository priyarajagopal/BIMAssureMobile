//
//  INVRuleInstanceDetailTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVRuleInstanceActualParamTableViewCell;

@protocol INVRuleInstanceActualParamTableViewCellDelegate <NSObject>
-(void)onRuleInstanceActualParamUpdated:(INVRuleInstanceActualParamTableViewCell*)sender;
-(void)onBeginEditingRuleInstanceActualParamField:(INVRuleInstanceActualParamTableViewCell*)sender;
@end

@interface INVRuleInstanceActualParamTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKey;
@property (weak, nonatomic) IBOutlet UITextField *ruleInstanceValue;
@property (weak, nonatomic) id<INVRuleInstanceActualParamTableViewCellDelegate> delegate;
@end
