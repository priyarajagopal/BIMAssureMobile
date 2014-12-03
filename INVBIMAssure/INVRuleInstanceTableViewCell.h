//
//  INVRuleInstanceTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVRuleInstanceTableViewCell;


@protocol INVRuleInstanceTableViewCellActionDelegate <NSObject>
@optional
-(void)onViewRuleTappedFor:(INVRuleInstanceTableViewCell*)sender;
-(void)onDeleteRuleTappedFor:(INVRuleInstanceTableViewCell*)sender;

@end

@protocol INVRuleInstanceTableViewCellStateDelegate <NSObject>
- (void)cellDidOpen:(INVRuleInstanceTableViewCell *)cell;
- (void)cellDidClose:(INVRuleInstanceTableViewCell *)cell;

@end

@interface INVRuleInstanceTableViewCell : UITableViewCell
@property (assign, nonatomic) NSNumber* ruleInstanceId;
@property (assign, nonatomic) NSNumber* ruleSetId;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *overview;
@property (weak, nonatomic) id<INVRuleInstanceTableViewCellActionDelegate> actionDelegate;
@property (weak, nonatomic) id<INVRuleInstanceTableViewCellStateDelegate> stateDelegate;

- (void)openCell;
@end
