//
//  INVGeneralAddRemoveTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/5/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVGeneralAddRemoveTableViewCell;

/**
 Notification to indicate if the file is to be moved from/to rule set. It is fired in addition to notofying any delegates via addRemoveFileTapped call
 */
extern NSString* const INV_NotificationAddRemoveCell ;

@protocol INVGeneralAddRemoveTableViewCellAcionDelegate <NSObject>
-(void)addRemoveFileTapped:(INVGeneralAddRemoveTableViewCell*)sender;
@end

@interface INVGeneralAddRemoveTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *addRemoveButton;
@property (assign, nonatomic) BOOL isAdded;
@property (assign, nonatomic) NSNumber* contentId;

@property (weak, nonatomic) id<INVGeneralAddRemoveTableViewCellAcionDelegate> actionDelegate;

- (IBAction)onAddRemoveButtonTapped:(UIButton *)sender;


@end
