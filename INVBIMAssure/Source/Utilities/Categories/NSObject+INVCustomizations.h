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

- (void)bindKeyPath:(NSString *)keyPath toObject:(id)object;
- (void)bindKeyPath:(NSString *)keyPath toObject:(id)object keyPath:(NSString *)keyPath;
- (void)bindKeyPath:(NSString *)keyPath toObject:(id)object keyPath:(NSString *)keyPath bothWays:(BOOL)bothWays;

- (void)unbindKeyPath:(NSString *)keypath;
- (void)unbindKeyPath:(NSString *)keypath fromObject:(id)object;
- (void)unbindKeyPath:(NSString *)keypath fromObject:(id)object keyPath:(NSString *)keyPath;
- (void)unbindKeyPath:(NSString *)keypath fromObject:(id)object keyPath:(NSString *)keyPath bothWays:(BOOL)bothWays;

@end
