//
//  INVPendingInviteCell.h
//  INVBIMAssure
//
//  Created by Richard Ross on 2/18/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVPendingInviteCell : UITableViewCell

@property (nonatomic) INVInvite *invite;
@property (nonatomic) INVUser *invitedBy;

@end
