//
//  INVRuleSetTableViewHeaderView.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/31/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVRuleSetTableViewHeaderView.h"

@implementation INVRuleSetTableViewHeaderView

- (void)awakeFromNib {
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)onAddRuleInstanceForRuleSet:(UIButton *)sender {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onAddRuleInstanceTapped:)]) {
        [self.actionDelegate onAddRuleInstanceTapped:self];
    }
}

-(IBAction)onManageFilesForRuleset:(UIButton*)sender {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onManageFilesTapped:)]) {
        [self.actionDelegate onManageFilesTapped:self];
    }
}

@end
