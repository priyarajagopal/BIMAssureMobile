//
//  INVSubscriptionLevelsTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVSubscriptionLevelsTableViewCell : UITableViewCell

- (IBAction)onProfessionalViewTapped:(UITapGestureRecognizer *)sender;
- (IBAction)onTeamViewTapped:(UITapGestureRecognizer *)sender;
- (IBAction)onEnterpriseViewTapped:(UITapGestureRecognizer *)sender;

@end
