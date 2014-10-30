//
//  INVRuleInstanceTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol INVRuleInstanceTableViewCellActionDelegate <NSObject>
-(void)onEditRuleTapped;
@end

@protocol INVRuleInstanceTableViewCellStateDelegate <NSObject>
- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;

@end

@interface INVRuleInstanceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *overview;
@property (weak, nonatomic) id<INVRuleInstanceTableViewCellActionDelegate> actionDelegate;
@property (weak, nonatomic) id<INVRuleInstanceTableViewCellStateDelegate> stateDelegate;

- (void)openCell;
@end
