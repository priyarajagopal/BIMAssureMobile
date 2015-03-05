//
//  INVAccountViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVAccountViewCell.h"
#import "INVAccountListViewController.h"

@interface INVAccountViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *accountThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (weak, nonatomic) IBOutlet UILabel *projectCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCountLabel;

@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (weak, nonatomic) IBOutlet UIImageView *isDefaultOverlayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *isCurrentlySignedInImageView;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *roleLabelBGView;

@end

@implementation INVAccountViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    UILongPressGestureRecognizer *longPressRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongTap:)];

    [self.accountThumbnailImageView addGestureRecognizer:longPressRecognizer];

    UIColor *greenShade = [UIColor colorWithRed:79.0 / 255 green:154.0 / 255 blue:65.0 / 255 alpha:1.0];

    FAKFontAwesome *greenCheckIcon = [FAKFontAwesome checkCircleIconWithSize:30.0];
    [greenCheckIcon addAttribute:NSForegroundColorAttributeName value:greenShade];

    [self.isCurrentlySignedInImageView setImage:[greenCheckIcon imageWithSize:CGSizeMake(30, 30)]];

    [self.isCurrentlySignedInImageView setHidden:YES];
    [self updateUI];
}

- (void)updateUI
{
    if (self.account) {
        UIColor *greenShade = [UIColor colorWithRed:79.0 / 255 green:154.0 / 255 blue:65.0 / 255 alpha:1.0];

        self.nameLabel.text = self.account.name;
        self.descriptionLabel.text = self.account.overview;
        self.accountStatusLabel.text = self.account.disabled.boolValue ? NSLocalizedString(@"ACCOUNT_STATUS_DISABLED", nil)
                                                                       : NSLocalizedString(@"ACCOUNT_STATUS_ACTIVE", nil);

        self.accountStatusLabel.textColor = self.account.disabled.boolValue ? [UIColor redColor] : greenShade;

        if (self.descriptionLabel.text.length == 0) {
            self.descriptionLabel.text = NSLocalizedString(@"ACCOUNT_DESCRITPION_UNAVAILABLE", nil);
        }

        if (self.isCurrentlySignedIn) {
            [self.signInButton setTitleColor:greenShade forState:UIControlStateNormal];
            [self.signInButton setTitle:@"\uf058" forState:UIControlStateNormal];
            [self.isCurrentlySignedInImageView setHidden:NO];
        }
        else {
            [self.signInButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.signInButton setTitle:@"\uf08b" forState:UIControlStateNormal];
            [self.isCurrentlySignedInImageView setHidden:YES];
        }

#warning TODO Specify the membership role when available (Always admin for now)
        self.roleLabel.text = NSLocalizedString(@"INV_MEMBERSHIP_TYPE_ADMIN", nil);
        self.roleLabelBGView.backgroundColor = greenShade;

        INVAccount *accountForThumbnail = self.account;
        self.accountThumbnailImageView.image = nil;
        [[INVGlobalDataManager sharedInstance].invServerClient
            getThumbnailImageForAccount:self.account.accountId
                  withCompletionHandler:^(id result, INVEmpireMobileError *error) {
                      if (error) {
                          INVLogError(@"%@", error);
                          UIImage* image =  [UIImage imageNamed:@"ImageNotFound"];
                          self.accountThumbnailImageView.image = image;
                          return;
                      }

                      if (self.account != accountForThumbnail) {
                          // Thumbnail loaded AFTER this cell has been reused - don't replace the image.
                          return;
                      }

                      UIImage *image = [UIImage imageWithData:result];
                      self.accountThumbnailImageView.image = image;
                  }];
    }

    if (self.invite) {
        self.nameLabel.text = self.invite.accountName;
        self.descriptionLabel.text = NSLocalizedString(@" ", nil);
        self.roleLabelBGView.backgroundColor = [UIColor clearColor];
        self.roleLabel.text = NSLocalizedString(@"ACCOUNT_STATUS_INVITE", nil);
        self.roleLabel.textColor = [UIColor orangeColor];
    }

    if (self.isExpanded) {
        [self.expandButton setTitle:@"\uf077" forState:UIControlStateNormal];
    }
    else {
        [self.expandButton setTitle:@"\uf078" forState:UIControlStateNormal];
    }
}

- (void)setIsCurrentlySignedIn:(BOOL)isSignedIn
{
    _isCurrentlySignedIn = isSignedIn;

    [self updateUI];
}

- (void)setIsDefault:(BOOL)isDefault
{
    _isDefault = isDefault;

    if (isDefault) {
        [self.isDefaultOverlayImageView setAlpha:1];
    }
    else {
        [self.isDefaultOverlayImageView setAlpha:0];
    }
}

- (void)setIsExpanded:(BOOL)isExpanded
{
    _isExpanded = isExpanded;

    [self updateUI];
}

- (void)setAccount:(INVAccount *)account
{
    _account = account;
    _invite = nil;

    [self updateUI];
}

- (void)setInvite:(INVUserInvite *)invite
{
    _invite = invite;
    _account = nil;

    [self updateUI];
}

- (void)_handleLongTap:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [[UIApplication sharedApplication] sendAction:@selector(selectThumbnail:) to:nil from:self forEvent:nil];
    }
}

@end
