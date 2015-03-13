//
//  UIFont+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/9/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "UIFont+INVCustomizations.h"

@implementation UIFont (INVCustomizations)

- (UIFont *)italicFont
{
    return [self fontWithTraits:UIFontDescriptorTraitItalic];
}

- (UIFont *)boldFont
{
    return [self fontWithTraits:UIFontDescriptorTraitBold];
}

- (UIFont *)fontWithTraits:(UIFontDescriptorSymbolicTraits)traits
{
    UIFontDescriptor *fontDescriptor = [self fontDescriptor];
    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:traits];

    return [UIFont fontWithDescriptor:fontDescriptor size:0];
}

@end
