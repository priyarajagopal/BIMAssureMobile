//
//  NSObject+INVCustomizations.h
//  INVBIMAssure
//
//  Created by Richard Ross on 2/26/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (INVCustomizations)

- (id)addDeallocHandler:(void (^)(id))block;
- (void)removeDeallocHandler:(void (^)(id))block;

@end
