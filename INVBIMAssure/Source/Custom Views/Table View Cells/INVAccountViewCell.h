//
//  INVAccountViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EmpireMobileManager/INVUserInvite.h>

@interface INVAccountViewCell : UICollectionViewCell

@property (strong, nonatomic) INVAccount *account;
@property (strong, nonatomic) INVUserInvite *invite;

@property (assign, nonatomic) BOOL isCurrentlySignedIn;
@property (assign, nonatomic) BOOL isDefault;
@property (assign, nonatomic) BOOL isExpanded;

@end
