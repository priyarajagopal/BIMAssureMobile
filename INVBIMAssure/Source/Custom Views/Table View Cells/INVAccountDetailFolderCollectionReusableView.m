//
//  INVAccountDetailFolderCollectionReusableView.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAccountDetailFolderCollectionReusableView.h"
#import "UIFont+INVCustomizations.h"

@interface INVAccountDetailFolderCollectionReusableView ()

@property IBOutlet UILabel *accountOverviewLabel;

@property IBOutlet UILabel *createdByAtLabel;

@property IBOutlet UILabel *companyNameLabel;
@property IBOutlet UILabel *companyAddressLabel;

@property IBOutlet UILabel *numberEmployeesLabel;

@property IBOutlet UILabel *contactNameLabel;
@property IBOutlet UILabel *contactPhoneLabel;

@end

@implementation INVAccountDetailFolderCollectionReusableView

- (void)awakeFromNib
{
    [self updateUI];
}

- (void)updateUI
{
    self.accountOverviewLabel.text = self.account.overview;
    if (self.accountOverviewLabel.text.length == 0) {
        self.accountOverviewLabel.attributedText =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ACCOUNT_DESCRIPTION_UNAVAILABLE", nil)
                                            attributes:@{NSFontAttributeName : [self.accountOverviewLabel.font italicFont]}];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    self.createdByAtLabel.text =
        [NSString stringWithFormat:@"Created on %@", [dateFormatter stringFromDate:self.account.createdAt]];

    self.companyNameLabel.text = self.account.companyName;
    if (self.companyNameLabel.text.length == 0) {
        self.companyNameLabel.attributedText =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"COMPANY_NAME_UNAVAILABLE", nil)
                                            attributes:@{NSFontAttributeName : [self.companyNameLabel.font italicFont]}];
    }

    self.companyAddressLabel.text = self.account.companyAddress;
    if (self.companyAddressLabel.text.length == 0) {
        self.companyAddressLabel.attributedText =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"COMPANY_ADDRESS_UNAVAILABLE", nil)
                                            attributes:@{NSFontAttributeName : [self.companyAddressLabel.font italicFont]}];
    }

    self.numberEmployeesLabel.text = [self.account.numberEmployees description];
    if (self.numberEmployeesLabel.text.length == 0) {
        self.numberEmployeesLabel.attributedText =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NUMBER_EMPLOYEES_UNAVAILABLE", nil)
                                            attributes:@{NSFontAttributeName : [self.numberEmployeesLabel.font italicFont]}];
    }

    self.contactNameLabel.text = self.account.contactName;
    if (self.contactNameLabel.text.length == 0) {
        self.contactNameLabel.attributedText =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CONTACT_NAME_UNAVAILABLE", nil)
                                            attributes:@{NSFontAttributeName : [self.contactNameLabel.font italicFont]}];
    }

    self.contactPhoneLabel.text = self.account.contactPhone;
    if (self.contactPhoneLabel.text.length == 0) {
        self.contactPhoneLabel.attributedText =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CONTACT_PHONE_UNAVAILABLE", nil)
                                            attributes:@{NSFontAttributeName : [self.contactPhoneLabel.font italicFont]}];
    }
}

- (void)setAccount:(INVAccount *)account
{
    _account = account;

    [self updateUI];
}

@end
