//
//  INVGenericTextEntryTableViewCell.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVGenericTextEntryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelHeading;

@property (weak, nonatomic) IBOutlet UITextField *textFieldEntry;

@end
