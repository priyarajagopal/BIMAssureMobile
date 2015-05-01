//
//  INVPagingManager.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^pageFetchBlock)(NSInteger offset, NSInteger pageSize,CompletionHandler handler);
@protocol INVPagingManagerDelegate<NSObject>

- (void)onFetchedDataAtOffset:(NSInteger)offset pageSize:(NSInteger)size withError:(INVEmpireMobileError *)error;

@end

@interface INVPagingManager : NSObject
@property (nonatomic, weak) id<INVPagingManagerDelegate> delegate;

- (instancetype)initWithTotalCount:(NSInteger)count pageSize:(NSInteger)pageSize delegate:(id<INVPagingManagerDelegate>)delegate;

- (void)fetchPageFromCurrentOffsetUsingSelector:(SEL)selector onTarget:(id)target;

- (void)fetchPageFromCurrentOffsetUsingSelector:(SEL)selector onTarget:(id)target withAdditionalArguments:(NSArray*)args;

- (void)resetOffset;
@end
