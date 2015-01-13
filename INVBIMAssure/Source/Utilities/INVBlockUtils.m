//
//  INVBlockUtils.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVBlockUtils.h"

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

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
