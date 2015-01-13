//
//  INVSubscriptionLevelsTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVSubscriptionLevelsTableViewCell.h"

@implementation INVSubscriptionLevelsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onProfessionalViewTapped:(UITapGestureRecognizer *)sender {
    [self.profCheckLabel setHidden:NO];
    self.selectedSubscriptionType = INV_SUBSCRIPTION_LEVEL_PROFESSIONAL;
}

- (IBAction)onTeamViewTapped:(UITapGestureRecognizer *)sender {
    [self.teamCheckLabel setHidden:NO];
    self.selectedSubscriptionType = INV_SUBSCRIPTION_LEVEL_TEAM;
}

- (IBAction)onEnterpriseViewTapped:(UITapGestureRecognizer *)sender {
    [self.enterpriseCheckLabel setHidden:NO];
    self.selectedSubscriptionType = INV_SUBSCRIPTION_LEVEL_ENTERPRISE;
}
@end
