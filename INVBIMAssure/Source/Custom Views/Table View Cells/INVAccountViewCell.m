//
//  INVAccountViewCell.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVAccountViewCell.h"

@implementation INVAccountViewCell

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    
    UICollectionViewLayoutAttributes *attr = [layoutAttributes copy];
    self.overview.numberOfLines = 0;
    CGSize size = [self.overview sizeThatFits:CGSizeMake(CGRectGetWidth(layoutAttributes.frame),CGFLOAT_MAX)];
    CGRect newFrame = attr.frame;
    newFrame.size.height = size.height + 50;
     
    attr.frame = newFrame;
    
    return attr;
}



-(void)setIsDefault:(BOOL)isDefault {
    _isDefault = isDefault;
    
    if (isDefault) {
        [self setDefaultAccessoryLabel];
    }
    else {
        [self setNonDefaultAccessoryLabel];
    }
}

-(void)setDefaultAccessoryLabel {
    UIColor* greenColor = [UIColor colorWithRed:88.0/255 green:161.0/255 blue:150.0/255 alpha:1.0];
    FAKFontAwesome *isDefaultIcon = [FAKFontAwesome checkCircleIconWithSize:CGRectGetHeight(self.accessoryLabel.frame)];
    [isDefaultIcon addAttribute:NSForegroundColorAttributeName value:greenColor];
    self.accessoryLabel.attributedText = [isDefaultIcon attributedString];

}

-(void)setNonDefaultAccessoryLabel {
    FAKFontAwesome *isDefaultIcon = [FAKFontAwesome signOutIconWithSize:CGRectGetHeight(self.accessoryLabel.frame)];
    
    [isDefaultIcon addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]];
    self.accessoryLabel.attributedText = [isDefaultIcon attributedString];
}

@end
