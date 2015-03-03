//
//  NSArray+INVCustomizations.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/3/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (INVCustomizations)

- (NSArray *)arrayByApplyingExpression:(NSExpression *)expression;
- (NSArray *)arrayByApplyingBlock:(id (^)(id, NSUInteger, BOOL *))block;

@end
