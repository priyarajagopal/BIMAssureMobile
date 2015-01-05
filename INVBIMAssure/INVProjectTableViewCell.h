//
//  INVProjectTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVProjectTableViewCell;

@protocol INVProjectTableViewCellDelegate <NSObject>

@optional
-(void) onProjectDeleted:(INVProjectTableViewCell *) sender;

@end

@interface INVProjectTableViewCell : UITableViewCell

@property (weak, nonatomic) id<INVProjectTableViewCellDelegate> delegate;

@property (strong, nonatomic) NSNumber *projectId;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *createdOnLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (weak, nonatomic) IBOutlet UILabel *fileCount;
@property (weak, nonatomic) IBOutlet UILabel *userCount;

@end
