//
//  INVRoleSelectionTableViewCell.h
//  INVBIMAssure
//
//  Created by Richard Ross on 2/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - KVO
extern NSString *const KVO_INVRoleUpdated;
@interface INVRoleSelectionTableViewCell : UITableViewCell

@property (nonatomic) INV_MEMBERSHIP_TYPE role;

@end
