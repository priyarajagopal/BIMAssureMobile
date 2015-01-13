//
//  INVAccountViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVAccountViewCell.h"

@interface INVAccountViewCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *accessoryLabel;

@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectStatusLabel;

@end

@implementation INVAccountViewCell

-(void) updateUI {
    if (self.account) {
        self.nameLabel.text = self.account.name;
        self.descriptionLabel.text = self.account.overview;
        self.projectStatusLabel.text = self.account.disabled.boolValue ?
                    NSLocalizedString(@"ACCOUNT_STATUS_DISABLED", nil) :
                    NSLocalizedString(@"ACCOUNT_STATUS_ACTIVE", nil);
    
        if (self.descriptionLabel.text.length == 0) {
            self.descriptionLabel.text = NSLocalizedString(@"ACCOUNT_DESCRITPION_UNAVAILABLE", nil);
        }
    
        if (_isDefault) {
            self.accessoryLabel.textColor = [UIColor colorWithRed:88.0/255 green:161.0/255 blue:150.0/255 alpha:1.0];
            self.accessoryLabel.text = @"\uf058";
        } else {
            self.accessoryLabel.textColor = [UIColor grayColor];
            self.accessoryLabel.text = @"\uf08b";
        }
    }
    
    if (self.invite) {
        self.nameLabel.text = self.invite.accountName;
        self.descriptionLabel.text = NSLocalizedString(@"ACCOUNT_DESCRITPION_UNAVAILABLE", nil);
        self.projectStatusLabel.text = NSLocalizedString(@"ACCOUNT_STATUS_INVITE", nil);
        
        self.accessoryLabel.text = @"";
    }
}

-(void)setIsDefault:(BOOL)isDefault {
    _isDefault = isDefault;
    
    [self updateUI];
}

-(void) setAccount:(INVAccount *)account {
    _account = account;
    _invite = nil;
    
    [self updateUI];
}

-(void) setInvite:(INVUserInvite *)invite {
    _invite = invite;
    _account = nil;
    
    [self updateUI];
}

-(void) awakeFromNib {
    [self updateUI];
}

@end
