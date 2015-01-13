//
//  INVSubscriptionLevelsTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  INV_SUBSCRIPTION_LEVEL_PROFESSIONAL = 0,
  INV_SUBSCRIPTION_LEVEL_TEAM = 1,
  INV_SUBSCRIPTION_LEVEL_ENTERPRISE = 3,
}_INV_SUBSCRIPTION_LEVEL;

@interface INVSubscriptionLevelsTableViewCell : UITableViewCell

@property (nonatomic,assign)_INV_SUBSCRIPTION_LEVEL selectedSubscriptionType;
- (IBAction)onProfessionalViewTapped:(UITapGestureRecognizer *)sender;
- (IBAction)onTeamViewTapped:(UITapGestureRecognizer *)sender;
- (IBAction)onEnterpriseViewTapped:(UITapGestureRecognizer *)sender;
@property (weak, nonatomic) IBOutlet UILabel *profCheckLabel;
@property (weak, nonatomic) IBOutlet UILabel *teamCheckLabel;
@property (weak, nonatomic) IBOutlet UILabel *enterpriseCheckLabel;

@end
