//
//  INVAccountDetailFolderCollectionReusableView.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAccountDetailFolderCollectionReusableView.h"

@interface INVAccountDetailFolderCollectionReusableView ()

@property IBOutlet UILabel *accountNameLabel;
@property IBOutlet UILabel *accountOverviewLabel;
@property IBOutlet UILabel *accountTypeLabel;

@property IBOutlet UILabel *createdByAtLabel;

@property IBOutlet UILabel *companyNameLabel;
@property IBOutlet UILabel *companyAddressLabel;

@property IBOutlet UILabel *contactNameLabel;
@property IBOutlet UILabel *contactPhoneLabel;

@property IBOutlet UIButton *signInOutButton;

@end

@implementation INVAccountDetailFolderCollectionReusableView

- (void)awakeFromNib
{
    [self updateUI];
}

- (void)updateUI
{
    self.accountNameLabel.text = self.account.name;
    if (self.accountNameLabel.text.length == 0)
        self.accountNameLabel.text = @"Account name unavailable";

    self.accountOverviewLabel.text = self.account.overview;
    if (self.accountOverviewLabel.text.length == 0)
        self.accountOverviewLabel.text = @"Account description unavailable";

    self.accountTypeLabel.text = self.account.type;
    if (self.accountTypeLabel.text.length == 0)
        self.accountTypeLabel.text = @"Account type unavailable";

    self.createdByAtLabel.text =
        [NSString stringWithFormat:@"Created by %@ at %@", self.account.createdBy, self.account.createdAt];

    self.companyNameLabel.text = self.account.companyName;
    self.companyAddressLabel.text = self.account.companyAddress;
    self.contactNameLabel.text = self.account.companyName;
    self.companyAddressLabel.text = self.account.companyAddress;

    if ([INVGlobalDataManager.sharedInstance.defaultAccountId isEqual:self.account.accountId]) {
        NSMutableAttributedString *attributedLogoutString = [[NSMutableAttributedString alloc] init];

        [attributedLogoutString
            appendAttributedString:[[NSAttributedString alloc] initWithString:@"Sign Out "
                                                                   attributes:@{
                                                                       NSForegroundColorAttributeName : [UIColor darkTextColor],
                                                                       NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                   }]];

        [attributedLogoutString
            appendAttributedString:[[NSAttributedString alloc]
                                       initWithString:@""
                                           attributes:@{
                                               NSForegroundColorAttributeName : [UIColor darkTextColor],
                                               NSFontAttributeName : [UIFont fontWithName:@"FontAwesome" size:15]
                                           }]];

        [self.signInOutButton setAttributedTitle:attributedLogoutString forState:UIControlStateNormal];
    }
    else {
        NSMutableAttributedString *attributedLoginString = [[NSMutableAttributedString alloc] init];

        [attributedLoginString
            appendAttributedString:[[NSAttributedString alloc] initWithString:@"Sign In "
                                                                   attributes:@{
                                                                       NSForegroundColorAttributeName : [UIColor darkTextColor],
                                                                       NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                   }]];

        [attributedLoginString
            appendAttributedString:[[NSAttributedString alloc]
                                       initWithString:@""
                                           attributes:@{
                                               NSForegroundColorAttributeName : [UIColor darkTextColor],
                                               NSFontAttributeName : [UIFont fontWithName:@"FontAwesome" size:15]
                                           }]];

        [self.signInOutButton setAttributedTitle:attributedLoginString forState:UIControlStateNormal];
    }
}

- (void)setAccount:(INVAccount *)account
{
    _account = account;

    [self updateUI];
}

@end
