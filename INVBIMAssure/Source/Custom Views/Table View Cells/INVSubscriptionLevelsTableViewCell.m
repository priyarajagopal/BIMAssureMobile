//
//  INVSubscriptionLevelsTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVSubscriptionLevelsTableViewCell.h"
@import QuartzCore;

@implementation INVSubscriptionLevelsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setLayerShadowForView:self.profView];
    [self setLayerShadowForView:self.teamView];
    [self setLayerShadowForView:self.enterpriseView];
       
    UITapGestureRecognizer* profTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfessionalViewTapped:)];
    [self.profView addGestureRecognizer:profTapGesture];
    [self.profView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* teamTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTeamViewTapped:)];
    [self.teamView addGestureRecognizer:teamTapGesture];
    [self.teamView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* entTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onEnterpriseViewTapped:)];
    [self.enterpriseView addGestureRecognizer:entTapGesture];
    [self.enterpriseView setUserInteractionEnabled:YES];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
}

- (void)onProfessionalViewTapped:(UITapGestureRecognizer *)sender {
    [self.profCheckLabel setHidden:NO];
    [self.teamCheckLabel setHidden:YES];
    [self.enterpriseCheckLabel setHidden:YES];
    self.selectedSubscriptionType = INV_SUBSCRIPTION_LEVEL_PROFESSIONAL;
}

- (void)onTeamViewTapped:(UITapGestureRecognizer *)sender {
    [self.teamCheckLabel setHidden:NO];
    [self.profCheckLabel setHidden:YES];
    [self.enterpriseCheckLabel setHidden:YES];
    self.selectedSubscriptionType = INV_SUBSCRIPTION_LEVEL_TEAM;
}

- (void)onEnterpriseViewTapped:(UITapGestureRecognizer *)sender {
    [self.enterpriseCheckLabel setHidden:NO];
    [self.teamCheckLabel setHidden:YES];
    [self.profCheckLabel setHidden:YES];
    self.selectedSubscriptionType = INV_SUBSCRIPTION_LEVEL_ENTERPRISE;
}

#pragma mark -helper
-(void)setLayerShadowForView:(UIView*)view {
    [view.layer setBorderColor:(__bridge CGColorRef)([UIColor lightGrayColor])];
    [view.layer setCornerRadius:2.0f];
    [view.layer setBorderWidth:1.0f];
    [view.layer setShadowOffset:CGSizeMake(0, 0)];
    [view.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [view.layer setShadowOpacity:0.5];

}
@end
