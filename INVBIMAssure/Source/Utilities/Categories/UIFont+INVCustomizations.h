//
//  UIFont+INVCustomizations.h
//  INVBIMAssure
//
//  Created by Richard Ross on 2/9/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFont (INVCustomizations)

- (UIFont *)italicFont;
- (UIFont *)boldFont;
- (UIFont *)fontWithTraits:(UIFontDescriptorSymbolicTraits)traits;

@end
