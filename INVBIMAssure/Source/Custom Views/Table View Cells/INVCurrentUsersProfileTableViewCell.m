//
//  INVCurrentUsersProfileTableViewCell.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/10/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCurrentUsersProfileTableViewCell.h"

@interface INVCurrentUsersProfileTableViewCell ()

@property IBOutlet UILabel *firstNameLabel, *lastNameLabel;
@property IBOutlet UILabel *emailLabel;
@property IBOutlet UILabel *addressLabel, *phoneLabel;
@property IBOutlet UILabel *titleCompanyLabel;

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
    self.firstNameLabel.text = self.user.firstName;
    self.lastNameLabel.text = self.user.lastName;
    self.emailLabel.text = self.user.email;
    self.addressLabel.text = self.user.address;
    self.phoneLabel.text = self.user.phoneNumber;

    self.titleCompanyLabel.text = [NSString stringWithFormat:@"%@ at %@", self.user.title, self.user.companyName];

    if (self.expanded) {
        self.expandedContentView.hidden = NO;

        [self.expandedContentView removeConstraint:self.collapseContentViewConstraint];
    }
    else {
        self.expandedContentView.hidden = YES;

        [self.expandedContentView addConstraint:self.collapseContentViewConstraint];
    }

    [self setNeedsLayout];
    [self setNeedsUpdateConstraints];
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
