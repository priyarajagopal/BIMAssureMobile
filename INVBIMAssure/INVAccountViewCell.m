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
    CGSize size = [self.overview sizeThatFits:CGSizeMake(CGRectGetWidth(layoutAttributes.frame),CGFLOAT_MAX)];
    CGRect newFrame = attr.frame;
    newFrame.size.height = size.height + 50;
    
    attr.frame = newFrame;
    return attr;
}

-(void)setIsDefault:(BOOL)isDefault {
    if (isDefault) {
        UIColor* greenColor = [UIColor colorWithRed:95.0/255 green:173.0/255 blue:161.0/255 alpha:1.0];
        FAKFontAwesome *isDefaultIcon = [FAKFontAwesome checkCircleIconWithSize:self.frame.size.height/3];
        [isDefaultIcon addAttribute:NSForegroundColorAttributeName value:greenColor];
        self.accessoryLabel.attributedText = [isDefaultIcon attributedString];
    }
    else {
        FAKFontAwesome *isDefaultIcon = [FAKFontAwesome signOutIconWithSize:self.frame.size.height/3];
        [isDefaultIcon addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor]];
        self.accessoryLabel.attributedText = [isDefaultIcon attributedString];
    }
}

@end
