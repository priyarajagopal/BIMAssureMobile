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
    [super awakeFromNib];

    [self updateUI];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];

    [self updateUI];
}

- (void)_setText:(NSString *)text forLabel:(UILabel *)label withDefault:(NSString *)defaultString
{
    label.text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (label.text.length == 0) {
        label.attributedText = [[NSAttributedString alloc] initWithString:defaultString
                                                               attributes:@{NSFontAttributeName : label.font.italicFont}];
    }
}

- (void)_setOverviewText:(NSString *)overviewText
{
    [self _setText:overviewText
           forLabel:self.accountOverviewLabel
        withDefault:NSLocalizedString(@"ACCOUNT_DESCRIPTION_UNAVAILABLE", nil)];
}

- (void)_setCreatedByAtText:(NSString *)createdByAtText
{
    [self _setText:createdByAtText
           forLabel:self.createdByAtLabel
        withDefault:NSLocalizedString(@"CREATED_AT_BY_UNAVAILABLE", nil)];
}

- (void)_setCompanyNameText:(NSString *)companyNameText
{
    [self _setText:companyNameText
           forLabel:self.companyNameLabel
        withDefault:NSLocalizedString(@"COMPANY_NAME_UNAVAILABLE", nil)];
}

- (void)_setCompanyAddressText:(NSString *)companyAddressText
{
    [self _setText:companyAddressText
           forLabel:self.companyAddressLabel
        withDefault:NSLocalizedString(@"COMPANY_ADDRESS_UNAVAILABLE", nil)];
}

- (void)_setNumberOfEmployeesText:(NSString *)numberOfEmployeesText
{
    [self _setText:numberOfEmployeesText
           forLabel:self.numberEmployeesLabel
        withDefault:NSLocalizedString(@"NUMBER_EMPLOYEES_UNAVAILABLE", nil)];
}

- (void)_setContactNameText:(NSString *)contactNameText
{
    [self _setText:contactNameText
           forLabel:self.contactNameLabel
        withDefault:NSLocalizedString(@"CONTACT_NAME_UNAVAILABLE", nil)];
}

- (void)_setContactPhoneText:(NSString *)contactPhoneText
{
    [self _setText:contactPhoneText
           forLabel:self.contactPhoneLabel
        withDefault:NSLocalizedString(@"CONTACT_PHONE_UNAVAILABLE", nil)];
}

- (void)updateUI
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    if (self.account) {
        [self _setOverviewText:self.account.overview];
        [self _setCreatedByAtText:[NSString stringWithFormat:@"Created on %@",
                                            [dateFormatter stringFromDate:self.account.createdAt]]];

        [self _setCompanyNameText:self.account.companyName];
        [self _setCompanyAddressText:self.account.companyAddress];
        [self _setNumberOfEmployeesText:[self.account.numberEmployees stringValue]];
        [self _setContactNameText:self.account.contactName];
        [self _setContactPhoneText:self.account.contactPhone];
    }
    else if (self.invite) {
        [self _setOverviewText:nil];
        [self _setCreatedByAtText:[NSString
                                      stringWithFormat:@"Sent on %@", [dateFormatter stringFromDate:self.invite.createdAt]]];

        [self _setCompanyNameText:nil];
        [self _setCompanyAddressText:nil];
        [self _setNumberOfEmployeesText:nil];
        [self _setContactNameText:nil];
        [self _setContactPhoneText:nil];
    }
}

- (void)setAccount:(INVAccount *)account
{
    _invite = nil;
    _account = account;

    [self updateUI];
}

- (void)setInvite:(INVUserInvite *)invite
{
    _account = nil;
    _invite = invite;

    [self updateUI];
}

@end
