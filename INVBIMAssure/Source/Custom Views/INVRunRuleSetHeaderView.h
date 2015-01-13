//
//  INVRunRuleSetHeaderView.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/2/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVRunRuleSetHeaderView;

@protocol INVRunRuleSetHeaderViewActionDelegate <NSObject>
-(void)onRuleSetToggled:(INVRunRuleSetHeaderView*)sender;
@end


@interface INVRunRuleSetHeaderView : UIView
@property (weak,nonatomic)id<INVRunRuleSetHeaderViewActionDelegate> actionDelegate;
@property (weak, nonatomic) IBOutlet UILabel *ruleSetNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *runRuleSetToggleButton;
@property (copy, nonatomic) NSNumber* ruleSetId;

- (IBAction)onRunRuleSetToggled:(UIButton *)sender;

@end
