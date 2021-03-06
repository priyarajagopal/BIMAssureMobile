//
//  INVGeneralAddRemoveTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/5/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVGeneralAddRemoveTableViewCell.h"

NSString *const INV_NotificationAddRemoveCell = @"NotificationAddRemoveCell";

@implementation INVGeneralAddRemoveTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsAdded:(BOOL)isAdded
{
    _isAdded = isAdded;
    if (!_isAdded) {
        UIColor *greenColor = [UIColor colorWithRed:88.0 / 255 green:161.0 / 255 blue:150.0 / 255 alpha:1.0];
        FAKFontAwesome *addIcon = [FAKFontAwesome plusCircleIconWithSize:30];
        [addIcon addAttribute:NSForegroundColorAttributeName value:greenColor];
        [self.addRemoveButton setAttributedTitle:[addIcon attributedString] forState:UIControlStateNormal];
    }
    else {
        UIColor *redColor = [UIColor redColor];
        FAKFontAwesome *removeIcon = [FAKFontAwesome minusCircleIconWithSize:30];
        [removeIcon addAttribute:NSForegroundColorAttributeName value:redColor];
        [self.addRemoveButton setAttributedTitle:[removeIcon attributedString] forState:UIControlStateNormal];
    }
}

#pragma mark - UIEvent handlers
- (IBAction)onAddRemoveButtonTapped:(UIButton *)sender
{
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(addRemoveFileTapped:)]) {
        [self.actionDelegate addRemoveFileTapped:self];
    }

    NSDictionary *userInfo = @{ @"AddRemoveCell" : self };
    NSNotification *note = [NSNotification notificationWithName:INV_NotificationAddRemoveCell object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

@end
