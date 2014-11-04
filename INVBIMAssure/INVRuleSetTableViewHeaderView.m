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
    UIColor* darkGreyColor = [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(IBAction)onManageFilesForRuleset:(UIButton*)sender {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onManageFilesTapped:)]) {
        [self.actionDelegate onManageFilesTapped:sender];
    }
}

@end
