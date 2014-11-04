//
//  INVRuleSetTableViewHeaderView.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol INVRuleSetTableViewHeaderViewAcionDelegate <NSObject>
-(void)onManageFilesTapped:(id)sender;
@end

@interface INVRuleSetTableViewHeaderView : UIView
@property (weak,nonatomic)id<INVRuleSetTableViewHeaderViewAcionDelegate> actionDelegate;
@property (weak, nonatomic) IBOutlet UILabel *ruleSetNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *manageFilesButton;
@property (assign, nonatomic) NSNumber* ruleSetId;

-(IBAction)onManageFilesForRuleset:(UIButton*)sender;
@end
