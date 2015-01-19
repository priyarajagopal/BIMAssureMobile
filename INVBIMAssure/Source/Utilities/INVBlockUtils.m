//
//  INVBlockUtils.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVBlockUtils.h"

@implementation INVBlockUtils

+(id) blockForExecutingBlock:(id)theBlock afterNumberOfCalls:(NSUInteger)targetCalls {
    theBlock = [theBlock copy];
    
    __block NSUInteger currentCalls = 0;
    
    return ^{
        if (++currentCalls == targetCalls) {
            [theBlock invoke];
        }
    };
}

@end
