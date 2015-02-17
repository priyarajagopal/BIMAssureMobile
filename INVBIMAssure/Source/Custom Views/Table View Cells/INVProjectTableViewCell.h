//
//  INVProjectTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVProjectTableViewCell;

@protocol INVProjectTableViewCellDelegate<NSObject>

@optional
- (void)onProjectDeleted:(INVProjectTableViewCell *)sender;
- (void)onProjectEdited:(INVProjectTableViewCell *)sender;

@end

@interface INVProjectTableViewCell : UITableViewCell

@property (weak, nonatomic) id<INVProjectTableViewCellDelegate> delegate;
@property (strong, nonatomic) INVProject *project;

@end
