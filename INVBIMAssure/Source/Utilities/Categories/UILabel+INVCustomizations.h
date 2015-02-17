//
//  UILabel+INVCustomizations.h
//  INVBIMAssure
//
//  Created by Richard Ross on 2/17/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (INVCustomizations)

- (void)setText:(NSString *)text withDefault:(NSString *)defaultLocalizedKey;
- (void)setText:(NSString *)text withDefault:(NSString *)defaultLocalizedKey andAttributes:(NSDictionary *)textAttributes;

@end
