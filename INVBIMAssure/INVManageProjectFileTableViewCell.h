//
//  INVManageProjectFileTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 11/5/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVManageProjectFileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UIButton *addRemoveButton;

- (IBAction)onAddRemoveButtonTapped:(UIButton *)sender;


@property (assign, nonatomic) BOOL isInRuleSet;
@end
