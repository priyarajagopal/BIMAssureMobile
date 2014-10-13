//
//  INVProjectTableViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/9/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectTableViewCell.h"

@implementation INVProjectTableViewCell

- (void)awakeFromNib {
    // Initialization code
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIView *bgColorView = [[UIView alloc] init];
    UIColor * ltBlueColor = [UIColor colorWithRed:194.0/255 green:224.0/255 blue:240.0/255 alpha:1.0];
    
    [bgColorView setBackgroundColor:ltBlueColor];
    [self setSelectedBackgroundView:bgColorView];

}


@end
