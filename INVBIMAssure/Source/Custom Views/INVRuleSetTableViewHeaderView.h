//
//  INVRuleSetTableViewHeaderView.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVRuleSetTableViewHeaderView;

@protocol INVRuleSetTableViewHeaderViewAcionDelegate <NSObject>
-(void)onManageFilesTapped:(INVRuleSetTableViewHeaderView*)sender;
-(void)onAddRuleInstanceTapped:(INVRuleSetTableViewHeaderView*)sender;
@end

@interface INVRuleSetTableViewHeaderView : UIView
@property (weak,nonatomic)id<INVRuleSetTableViewHeaderViewAcionDelegate> actionDelegate;
@property (weak, nonatomic) IBOutlet UILabel *ruleSetNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *manageFilesButton;
@property (copy, nonatomic) NSNumber* ruleSetId;
@property (weak, nonatomic) IBOutlet UIButton *addRuleButton;

- (IBAction)onAddRuleInstanceForRuleSet:(UIButton *)sender;
-(IBAction)onManageFilesForRuleset:(UIButton*)sender;
@end
