//
//  INVPagingManager.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVPagingManager.h"
//#import "INVPagingManager+Private.h"

const NSInteger DEFAULT_PAGESIZE = 20;

@interface INVPagingManager ()
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger currOffset;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL stopFetching;

@end
@implementation INVPagingManager

- (instancetype)initWithTotalCount:(NSInteger)totalCount
                          pageSize:(NSInteger)pageSize
                          delegate:(id<INVPagingManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.totalCount = totalCount;
        self.currOffset = 0;
        self.pageSize = pageSize;
        self.delegate = delegate;
        self.stopFetching = NO;
    }
    return self;
}

- (id)init
{
    return [self initWithTotalCount:0 pageSize:0 delegate:nil];
}

#pragma mark - public methods
- (void)resetOffset
{
    self.currOffset = 0;
    self.stopFetching = NO;
}

- (void)handlePagedResponse:(INVEmpireMobileError *)error
{
    if (error.code.integerValue == INV_ERROR_CODE_NOMOREPAGES) {
        self.stopFetching = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onFetchedDataAtOffset:pageSize:withError:)]) {
        [self.delegate onFetchedDataAtOffset:self.currOffset pageSize:self.pageSize withError:error];
    }

    self.currOffset += self.pageSize;
}

- (void)fetchPageFromCurrentOffsetUsingSelector:(SEL)selector onTarget:(id)target withAdditionalArguments:(NSArray *)args
{
    if (self.stopFetching) {
        [self handlePagedResponse:[[INVEmpireMobileError alloc] initWithDictionary:@{
            @"code" : @(INV_ERROR_CODE_NOMOREPAGES),
            @"message" : INV_ERROR_MESG_NOMOREPAGES
        } error:nil]];
    }
    else {
        if ([target respondsToSelector:selector]) {
            NSInvocation *invocation =
                [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];

            CompletionHandler handler = ^(INVEmpireMobileError *error) {
                [self handlePagedResponse:error];
            };

            [invocation setSelector:selector];
            NSNumber *offset = @(self.currOffset);
            NSNumber *pageSize = @(self.pageSize);

            // Argument 1 is at index 2, as there is self and _cmd
            NSInteger argStartIndex = 2;
            [args enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                id argument = obj;
                [invocation setArgument:&argument atIndex:argStartIndex + idx];

            }];
            argStartIndex += args.count;
            [invocation setArgument:&offset atIndex:argStartIndex];
            [invocation setArgument:&pageSize atIndex:argStartIndex + 1];
            [invocation setArgument:&handler atIndex:argStartIndex + 2];

            [invocation invokeWithTarget:target];
            [invocation retainArguments];
        }
    }
}

- (void)fetchPageFromCurrentOffsetUsingSelector:(SEL)selector onTarget:(id)target
{
    return [self fetchPageFromCurrentOffsetUsingSelector:selector onTarget:target withAdditionalArguments:nil];
}

@end
