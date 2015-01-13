//
//  INVGenericSwitchTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVGenericSwitchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *toggleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;

@end
