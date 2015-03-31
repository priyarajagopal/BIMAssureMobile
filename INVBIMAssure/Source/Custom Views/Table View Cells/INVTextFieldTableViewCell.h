//
//  INVRuleInstanceNameTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/20/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVTextFieldTableViewCell;
@protocol INVTextFieldTableViewCellDelegate<NSObject>
- (void)onTextFieldUpdated:(INVTextFieldTableViewCell *)sender;
- (void)onBeginEditingTextField:(INVTextFieldTableViewCell *)sender;
@end

@interface INVTextFieldTableViewCell : UITableViewCell
@property (weak, nonatomic) id<INVTextFieldTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *detail;

@end
