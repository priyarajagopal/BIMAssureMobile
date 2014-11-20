//
//  INVRuleInstanceOverviewTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/19/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVRuleInstanceOverviewTableViewCell;
@protocol INVRuleInstanceOverviewTableViewCellDelegate <NSObject>
-(void)onRuleInstanceOverviewUpdated:(INVRuleInstanceOverviewTableViewCell*)sender;
-(void)onBeginEditingRuleInstanceOverviewField:(INVRuleInstanceOverviewTableViewCell*)sender;
@end


@interface INVRuleInstanceOverviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *ruleDescription;
@property (weak, nonatomic) id<INVRuleInstanceOverviewTableViewCellDelegate> delegate;

@end
