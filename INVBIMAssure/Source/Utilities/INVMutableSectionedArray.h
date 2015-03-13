//
//  INVMutableSectionedArray.h
//  INVBIMAssure
//
//  Created by Richard Ross on 3/12/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVMutableSectionedArraySection : NSObject

@property NSArray *array;
@property NSRange range;
@property id userInfo;

@end

// NSMutableArray subclass which contains a list of other arrays
@interface INVMutableSectionedArray : NSMutableArray

- (id)rawObjectAtIndex:(NSUInteger)index;
- (NSUInteger)rawIndexOfObject:(id)object;

- (void)insertArray:(NSArray *)array atIndex:(NSUInteger)index;
- (NSArray *)sections;

@end
