//
//  INVSubscriptionLevelsTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVSubscriptionLevelsTableViewCell.h"
@import QuartzCore;

static NSString* const INV_SUBSCRIPTION_STORAGE    = @"Storage";
static NSString* const INV_SUBSCRIPTION_ANALYSIS   = @"Analysis";
static NSString* const INV_SUBSCRIPTION_USERS      = @"Users";
static NSString* const INV_SUBSCRIPTION_TIER1RULES = @"Tier1 Rules";
static NSString* const INV_SUBSCRIPTION_PRICING    = @"Pricing";


@interface INVSubscriptionLevelsTableViewCell ()

@property (nonatomic,strong) NSDictionary* enterpriseSubscriptionDetails;
@property (nonatomic,strong) NSDictionary* professionalSubscriptionDetails;
@property (nonatomic,strong) NSDictionary* teamSubscriptionDetails;

@end
@implementation INVSubscriptionLevelsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self populateWithSubscriptionDetails];
    
    [self addToView:self.enterpriseView subscriptionDetails:self.enterpriseSubscriptionDetails];
    [self addToView:self.profView subscriptionDetails:self.professionalSubscriptionDetails];
    [self addToView:self.teamView subscriptionDetails:self.teamSubscriptionDetails];
    
    
    [self setLayerShadowForView:self.profView];
    [self setLayerShadowForView:self.teamView];
    [self setLayerShadowForView:self.enterpriseView];
    
    self.selectedSubscriptionType = INV_SUBSCRIPTION_LEVEL_TEAM;

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

#pragma mark -helpers

-(void)addToView:(UIView*)view subscriptionDetails:(NSDictionary*)details{
    __block NSInteger yOffset = 40;
    NSInteger xOffset = 10;
    
    [details enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* heading = key;
        NSString* value = obj;
        NSMutableAttributedString * detail = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@"%@:%@",heading,value ]];
        
        NSMutableDictionary *attr = [[NSMutableDictionary alloc]initWithCapacity:0];
        attr[NSFontAttributeName] = [UIFont boldSystemFontOfSize:14.0];
        [detail setAttributes:attr range:NSMakeRange(0, heading.length)] ;
        
        attr[NSFontAttributeName] = [UIFont systemFontOfSize:14.0];
        [detail setAttributes:attr range:NSMakeRange(heading.length, value.length)] ;
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(xOffset, yOffset, CGRectGetWidth(view.frame)- (xOffset *2), 20)];
        [label setBackgroundColor:[UIColor clearColor] ];
        [label setAttributedText:detail];
        [label setTextColor:[UIColor darkTextColor]];
        [view addSubview:label];
        
        yOffset += 30;
    }];
}

-(void)setLayerShadowForView:(UIView*)view {
    [view.layer setBorderColor:(__bridge CGColorRef)([UIColor lightGrayColor])];
    [view.layer setCornerRadius:2.0f];
    [view.layer setBorderWidth:1.0f];
    [view.layer setShadowOffset:CGSizeMake(0, 0)];
    [view.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [view.layer setShadowOpacity:0.5];

}

-(void)populateWithSubscriptionDetails {
    
#warning Ideally we should have the subscription info fetched from server and the units should be localized probably
    self.professionalSubscriptionDetails = @{INV_SUBSCRIPTION_STORAGE:@"250 MB", INV_SUBSCRIPTION_ANALYSIS:@"500 MB", INV_SUBSCRIPTION_USERS: @"unlimited", INV_SUBSCRIPTION_TIER1RULES:@"unlimited", INV_SUBSCRIPTION_PRICING:@"$99/mo"};
    self.teamSubscriptionDetails         = @{INV_SUBSCRIPTION_STORAGE:@"1 GB", INV_SUBSCRIPTION_ANALYSIS:@"2 GB", INV_SUBSCRIPTION_USERS: @"unlimited", INV_SUBSCRIPTION_TIER1RULES:@"unlimited", INV_SUBSCRIPTION_PRICING:@"$299/mo"};
    self.enterpriseSubscriptionDetails   = @{INV_SUBSCRIPTION_STORAGE:@"4 GB", INV_SUBSCRIPTION_ANALYSIS:@"8 GB", INV_SUBSCRIPTION_USERS: @"unlimited", INV_SUBSCRIPTION_TIER1RULES:@"unlimited", INV_SUBSCRIPTION_PRICING:@"$999/mo"};
    
    
}
@end
