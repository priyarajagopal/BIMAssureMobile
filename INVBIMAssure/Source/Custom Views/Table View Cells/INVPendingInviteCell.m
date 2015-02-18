//
//  INVPendingInviteCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/18/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVPendingInviteCell.h"
#import "UILabel+INVCustomizations.h"

@interface INVPendingInviteCell ()

@property IBOutlet UILabel *emailLabel;
@property IBOutlet UILabel *invitedFirstNameLabel;
@property IBOutlet UILabel *invitedLastNameLabel;
@property IBOutlet UILabel *invitedDateLabel;

@end

@implementation INVPendingInviteCell

+ (NSDateFormatter *)invitedAtDateFormatter
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    });

    return dateFormatter;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self updateUI];
}

- (void)setInvite:(INVInvite *)invite
{
    _invite = invite;

    [self updateUI];
}

- (void)setInvitedBy:(INVUser *)invitedBy
{
    _invitedBy = invitedBy;

    [self updateUI];
}

- (void)updateUI
{
    [self.emailLabel setText:self.invite.email withDefault:@"EMAIL_UNAVAILABLE"];

    [self.invitedFirstNameLabel setText:self.invitedBy.firstName withDefault:@"FIRST_NAME_UNAVAILABLE"];
    [self.invitedLastNameLabel setText:self.invitedBy.lastName withDefault:@"LAST_NAME_UNAVAILABLE"];
    [self.invitedDateLabel setText:[[INVPendingInviteCell invitedAtDateFormatter] stringFromDate:self.invite.createdAt]
                       withDefault:@"INVITATION_DATE_UNAVAILABLE"];
}

@end
