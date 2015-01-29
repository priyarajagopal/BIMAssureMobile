//
//  INVBlockUtils.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/13/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVBlockUtils : NSObject

+ (id)blockForExecutingBlock:(id)theBlock afterNumberOfCalls:(NSUInteger)targetCalls;

@end
