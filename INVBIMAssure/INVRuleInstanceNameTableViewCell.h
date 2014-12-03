//
//  INVRuleInstanceNameTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/20/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVRuleInstanceNameTableViewCell;
@protocol INVRuleInstanceNameTableViewCellDelegate <NSObject>
-(void)onRuleInstanceNameUpdated:(INVRuleInstanceNameTableViewCell*)sender;
-(void)onBeginEditingRuleInstanceNameField:(INVRuleInstanceNameTableViewCell*)sender;
@end

@interface INVRuleInstanceNameTableViewCell : UITableViewCell
@property (weak, nonatomic) id<INVRuleInstanceNameTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *ruleName;

@end
