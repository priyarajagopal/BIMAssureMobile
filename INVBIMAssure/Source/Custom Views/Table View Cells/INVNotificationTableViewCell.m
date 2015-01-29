//
//  INVNotificationTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVNotificationTableViewCell.h"
#import "NSTimeIntervalToString.h"

@implementation INVNotificationTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];

    [self updateUI];
}

- (void)updateUI
{
    NSTimeInterval timeSinceCreation = -[_notification.creationDate timeIntervalSinceNow];

    self.titleLabel.text = _notification.title;
    self.createdAtLabel.text = NSTimeIntervalToStringAsAgo(timeSinceCreation);
}

- (void)setNotification:(INVNotification *)notification
{
    _notification = notification;

    [self updateUI];
}

@end
