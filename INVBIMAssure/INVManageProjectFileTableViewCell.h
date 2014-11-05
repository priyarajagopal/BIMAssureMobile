//
//  INVManageProjectFileTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/5/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVManageProjectFileTableViewCell;

@protocol INVManageProjectFileTableViewCellAcionDelegate <NSObject>
-(void)addRemoveFileTapped:(INVManageProjectFileTableViewCell*)sender;
@end

@interface INVManageProjectFileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UIButton *addRemoveButton;
@property (assign, nonatomic) BOOL isInRuleSet;
@property (weak, nonatomic) id<INVManageProjectFileTableViewCellAcionDelegate> actionDelegate;

- (IBAction)onAddRemoveButtonTapped:(UIButton *)sender;


@end
