//
//  INVRuleInstanceDetailTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVRuleInstanceDetailTableViewCell;

@protocol INVRuleInstanceDetailTableViewCellDelegate <NSObject>
-(void)onRuleInstanceUpdated:(INVRuleInstanceDetailTableViewCell*)sender;
-(void)onBeginEditingRuleInstanceField:(INVRuleInstanceDetailTableViewCell*)sender;
@end

@interface INVRuleInstanceDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ruleInstanceKey;
@property (weak, nonatomic) IBOutlet UITextField *ruleInstanceValue;
@property (weak, nonatomic) id<INVRuleInstanceDetailTableViewCellDelegate> delegate;
@end
