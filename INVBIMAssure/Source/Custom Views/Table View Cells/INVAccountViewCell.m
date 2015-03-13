//
//  INVAccountViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVAccountViewCell.h"
#import "INVAccountListViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

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
@property (strong, nonatomic) INVGlobalDataManager *globalDataManager;

@end

@implementation INVAccountViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.globalDataManager = [INVGlobalDataManager sharedInstance];

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
        self.alpha = self.account.disabled.boolValue ? 0.5 : 1;
        self.expandButton.hidden = self.account.disabled.boolValue;

        if (self.descriptionLabel.text.length == 0) {
            self.descriptionLabel.text = NSLocalizedString(@"ACCOUNT_DESCRITPION_UNAVAILABLE", nil);
        }

#warning TODO Specify the membership role when available (Always admin for now)
        self.roleLabel.text = NSLocalizedString(@"INV_MEMBERSHIP_TYPE_ADMIN", nil);
        self.roleLabel.textColor = [UIColor whiteColor];
        self.roleLabelBGView.backgroundColor = greenShade;

        INVAccount *accountForThumbnail = self.account;
        self.accountThumbnailImageView.image = nil;
        NSMutableURLRequest *acntThumbnail = [[self.globalDataManager.invServerClient
            requestToGetThumbnailImageForAccount:accountForThumbnail.accountId] mutableCopy];
        if ([self.globalDataManager isRecentlyEditedAccount:accountForThumbnail.accountId]) {
            [acntThumbnail setCachePolicy:NSURLRequestReloadIgnoringCacheData];
            [self.globalDataManager removeFromRecentlyEditedAccountList:accountForThumbnail.accountId];
        }

        [self.accountThumbnailImageView
            setImageWithURLRequest:acntThumbnail
                  placeholderImage:[UIImage imageNamed:@"ImageNotFound"]
                           success:nil
                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                               INVLogError(@"Failed to download image for account %@ with error %@",
                                   accountForThumbnail.accountId, error);
                           }];
    }

    if (self.invite) {
        self.alpha = 1;
        self.expandButton.hidden = YES;

        self.nameLabel.text = self.invite.accountName;
        self.descriptionLabel.text = NSLocalizedString(@" ", nil);
        self.roleLabelBGView.backgroundColor = [UIColor clearColor];
        self.roleLabel.text = NSLocalizedString(@"ACCOUNT_STATUS_INVITE", nil);
        self.roleLabel.textColor = [UIColor orangeColor];
    }
}

- (void)setIsCurrentlySignedIn:(BOOL)isSignedIn
{
    UIColor *greenShade = [UIColor colorWithRed:79.0 / 255 green:154.0 / 255 blue:65.0 / 255 alpha:1.0];
    _isCurrentlySignedIn = isSignedIn;

    if (_isCurrentlySignedIn) {
        [self.signInButton setTitleColor:greenShade forState:UIControlStateNormal];
        [self.signInButton setTitle:@"\uf058" forState:UIControlStateNormal];
        [self.isCurrentlySignedInImageView setHidden:NO];
    }
    else {
        [self.signInButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.signInButton setTitle:@"\uf08b" forState:UIControlStateNormal];
        [self.isCurrentlySignedInImageView setHidden:YES];
    }
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

    if (_isExpanded) {
        [self.expandButton setTitle:@"\uf077" forState:UIControlStateNormal];
    }
    else {
        [self.expandButton setTitle:@"\uf078" forState:UIControlStateNormal];
    }
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
