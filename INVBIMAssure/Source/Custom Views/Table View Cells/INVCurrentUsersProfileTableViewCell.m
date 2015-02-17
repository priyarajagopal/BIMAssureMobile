//
//  INVCurrentUsersProfileTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/10/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCurrentUsersProfileTableViewCell.h"

#import "UIFont+INVCustomizations.h"
#import "UILabel+INVCustomizations.h"

@interface INVCurrentUsersProfileTableViewCell ()

@property IBOutlet UILabel *firstNameLabel, *lastNameLabel;
@property IBOutlet UILabel *emailLabel;
@property IBOutlet UILabel *addressLabel, *phoneLabel;
@property IBOutlet UILabel *titleLabel, *companyLabel;

@property IBOutlet UIView *expandedContentView;
@property IBOutlet NSLayoutConstraint *collapseContentViewConstraint;

@end

@implementation INVCurrentUsersProfileTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self updateUI];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    UIEdgeInsets margins = self.contentView.layoutMargins;
    margins.left = 8 + (self.indentationLevel * self.indentationWidth);

    self.contentView.layoutMargins = margins;
}

- (void)updateUI
{
    NSDictionary *titleFontDicionary = @{NSFontAttributeName : [self.firstNameLabel.font italicFont]};
    NSDictionary *subtitleFontDicitonary = @{NSFontAttributeName : [self.emailLabel.font italicFont]};

    [self.firstNameLabel setText:self.user.firstName withDefault:@"USER_NAME_UNAVAILABLE" andAttributes:titleFontDicionary];
    [self.lastNameLabel setText:self.user.lastName withDefault:nil];

    [self.emailLabel setText:self.user.email withDefault:@"USER_EMAIL_UNAVAILABLE" andAttributes:subtitleFontDicitonary];
    [self.addressLabel setText:self.user.address withDefault:@"USER_ADDRESS_UNAVAILABLE" andAttributes:subtitleFontDicitonary];
    [self.phoneLabel setText:self.user.phoneNumber withDefault:@"USER_PHONE_UNAVAILABLE" andAttributes:subtitleFontDicitonary];

    [self.titleLabel setText:self.user.title withDefault:@"USER_TITLE_UNAVAILABLE" andAttributes:subtitleFontDicitonary];
    [self.companyLabel setText:self.user.companyName
                   withDefault:@"USER_COMPANY_UNAVAILABLE"
                 andAttributes:subtitleFontDicitonary];

    [self setNeedsLayout];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];

    if (self.expanded) {
        self.expandedContentView.hidden = NO;

        [self.expandedContentView removeConstraint:self.collapseContentViewConstraint];
    }
    else {
        self.expandedContentView.hidden = YES;

        [self.expandedContentView addConstraint:self.collapseContentViewConstraint];
    }
}

- (void)setUser:(INVUser *)user
{
    _user = user;

    [self updateUI];
}

- (void)setExpanded:(BOOL)expanded
{
    _expanded = expanded;

    [self updateUI];
}

@end
