//
//  INVAccountDetailFolderCollectionReusableView.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/5/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAccountDetailFolderCollectionReusableView.h"
#import "UIFont+INVCustomizations.h"

#import "UILabel+INVCustomizations.h"

@interface INVAccountDetailFolderCollectionReusableView ()

@property IBOutlet UILabel *accountOverviewLabel;

@property IBOutlet UILabel *createdByAtLabel;

@property IBOutlet UILabel *companyNameLabel;
@property IBOutlet UILabel *companyAddressLabel;

@property IBOutlet UILabel *numberEmployeesLabel;

@property IBOutlet UILabel *contactNameLabel;
@property IBOutlet UITextView *contactPhoneLabel;

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

- (void)updateUI
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    NSDictionary *italicFontAttributes = @{NSFontAttributeName : self.accountOverviewLabel.font.italicFont};

    if (self.account) {
        [self.accountOverviewLabel setText:self.account.overview
                               withDefault:@"ACCOUNT_DESCRIPTION_UNAVAILABLE"
                             andAttributes:italicFontAttributes];

        [self.createdByAtLabel
                setText:[NSString stringWithFormat:@"Created on %@", [dateFormatter stringFromDate:self.account.createdAt]]
            withDefault:nil];

        [self.companyNameLabel setText:self.account.companyName
                           withDefault:@"COMPANY_NAME_UNAVAILABLE"
                         andAttributes:italicFontAttributes];

        [self.companyAddressLabel setText:self.account.companyAddress
                              withDefault:@"COMPANY_ADDRESS_UNAVAILABLE"
                            andAttributes:italicFontAttributes];

        [self.numberEmployeesLabel setText:self.account.numberEmployees.stringValue
                               withDefault:@"NUMBER_EMPLOYEES_UNAVAILABLE"
                             andAttributes:italicFontAttributes];

        [self.contactNameLabel setText:self.account.contactName
                           withDefault:@"CONTACT_NAME_UNAVAILABLE"
                         andAttributes:italicFontAttributes];

        [self.contactPhoneLabel setText:self.account.contactPhone
                            withDefault:@"CONTACT_PHONE_UNAVAILABLE"
                          andAttributes:italicFontAttributes];
    }
    else if (self.invite) {
        [self.accountOverviewLabel setText:nil
                               withDefault:@"ACCOUNT_DESCRIPTION_UNAVAILABLE"
                             andAttributes:italicFontAttributes];

        [self.createdByAtLabel
                setText:[NSString stringWithFormat:@"Created on %@", [dateFormatter stringFromDate:self.invite.createdAt]]
            withDefault:nil];

        [self.companyNameLabel setText:nil withDefault:@"COMPANY_NAME_UNAVAILABLE" andAttributes:italicFontAttributes];
        [self.companyAddressLabel setText:nil withDefault:@"COMPANY_ADDRESS_UNAVAILABLE" andAttributes:italicFontAttributes];
        [self.numberEmployeesLabel setText:nil withDefault:@"NUMBER_EMPLOYEES_UNAVAILABLE" andAttributes:italicFontAttributes];
        [self.contactNameLabel setText:nil withDefault:@"CONTACT_NAME_UNAVAILABLE" andAttributes:italicFontAttributes];
        [self.contactPhoneLabel setText:nil withDefault:@"CONTACT_PHONE_UNAVAILABLE" andAttributes:italicFontAttributes];
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
