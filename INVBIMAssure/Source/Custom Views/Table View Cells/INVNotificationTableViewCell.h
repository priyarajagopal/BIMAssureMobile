//
//  INVNotificationTableViewCell.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "INVNotification.h"

@interface INVNotificationTableViewCell : UITableViewCell

@property IBOutlet UILabel *titleLabel;
@property IBOutlet UILabel *createdAtLabel;

@property (nonatomic, strong) INVNotification *notification;

@end
