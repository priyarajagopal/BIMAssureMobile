//
//  NSString+INVCustomizations.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "NSString+INVCustomizations.h"

@implementation NSString (INVCustomizations)
- (BOOL) isValidEmail {
    NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    
    
    NSString *emailText = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    __block BOOL isEmail = NO;
    
    [dataDetector enumerateMatchesInString:emailText
                                   options:0
                                     range:NSMakeRange(0, emailText.length)
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                    if (result.range.length == emailText.length &&
                                        result.resultType == NSTextCheckingTypeLink &&
                                        [result.URL.scheme isEqualToString:@"mailto"]) {
                                        isEmail = YES;
                                    }
                                }];
    
    return isEmail;
}
@end
