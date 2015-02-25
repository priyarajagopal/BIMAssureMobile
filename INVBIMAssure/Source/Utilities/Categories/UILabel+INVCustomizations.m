//
//  UILabel+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Richard Ross on 2/17/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "UILabel+INVCustomizations.h"

@implementation UILabel (INVCustomizations)

- (void)setText:(NSString *)text withDefault:(NSString *)defaultLocalizedKey
{
    [self setText:text withDefault:defaultLocalizedKey andAttributes:nil];
}

- (void)setText:(NSString *)text withDefault:(NSString *)defaultLocalizedKey andAttributes:(NSDictionary *)textAttriubtes;
{
    self.text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (self.text.length == 0) {
        self.attributedText =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(defaultLocalizedKey, nil) attributes:textAttriubtes];
    }
}

@end

@implementation UITextView (INVCustomizations)

- (void)setText:(NSString *)text withDefault:(NSString *)defaultLocalizedKey
{
    [self setText:text withDefault:defaultLocalizedKey andAttributes:nil];
}

- (void)setText:(NSString *)text withDefault:(NSString *)defaultLocalizedKey andAttributes:(NSDictionary *)textAttriubtes;
{
    self.text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (self.text.length == 0) {
        self.attributedText =
            [[NSAttributedString alloc] initWithString:NSLocalizedString(defaultLocalizedKey, nil) attributes:textAttriubtes];
    }
}

@end