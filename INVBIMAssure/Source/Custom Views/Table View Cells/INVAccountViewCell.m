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
        UIColor* greenShade = [UIColor colorWithRed:79.0/255 green:154.0/255 blue:65.0/255 alpha:1.0];;
        
        self.nameLabel.text = self.account.name;
        self.descriptionLabel.text = self.account.overview;
        self.projectStatusLabel.text = self.account.disabled.boolValue ?
                    NSLocalizedString(@"ACCOUNT_STATUS_DISABLED", nil) :
                    NSLocalizedString(@"ACCOUNT_STATUS_ACTIVE", nil);
        
        self.projectStatusLabel.textColor = self.account.disabled.boolValue ? [UIColor redColor] : greenShade;
    
        if (self.descriptionLabel.text.length == 0) {
            self.descriptionLabel.text = NSLocalizedString(@"ACCOUNT_DESCRITPION_UNAVAILABLE", nil);
        }
    
        if (self.isCurrentlySignedIn) {
            self.accessoryLabel.textColor = greenShade;
            self.accessoryLabel.text = @"\uf058";
        }
        else {
            self.accessoryLabel.textColor = [UIColor grayColor];
            self.accessoryLabel.text = @"\uf08b";
        }
    }
    
    if (self.invite) {
        self.nameLabel.text = self.invite.accountName;
        self.descriptionLabel.text = NSLocalizedString(@"ACCOUNT_DESCRITPION_UNAVAILABLE", nil);
        self.projectStatusLabel.text = NSLocalizedString(@"ACCOUNT_STATUS_INVITE", nil);
        self.projectStatusLabel.textColor = [UIColor orangeColor];
        
        self.accessoryLabel.text = @"";
    }
}

-(void)setIsCurrentlySignedIn:(BOOL)isSignedIn {
    _isCurrentlySignedIn = isSignedIn;
    
    [self updateUI];
}

-(void)setIsDefault:(BOOL)isDefault {
    _isDefault = isDefault;
    
    if (isDefault) {
        [self.isDefaultOverlayImageView setHidden:NO];
    }
    else {
        [self.isDefaultOverlayImageView setHidden:YES];
    }
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
