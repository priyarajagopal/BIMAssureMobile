//
//  INVPagingManager+ProjectListing.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVPagingManager+ProjectListing.h"
#import "INVPagingManager+Private.h"

@implementation INVPagingManager (ProjectListing)

- (void)fetchProjectsFromCurrentOffset
{
    if (self.currOffset >= self.totalCount) {
        [self handlePagedResponse:[[INVEmpireMobileError alloc] initWithDictionary:@{
            @"code" : @(INV_ERROR_CODE_NOMOREPAGES),
            @"message" : INV_ERROR_MESG_NOMOREPAGES
        } error:nil]];
    }
    [self.globalDataManager.invServerClient getAllProjectsForSignedInAccountWithOffset:@(self.currOffset)
                                                                              pageSize:@(self.pageSize)
                                                                   WithCompletionBlock:^(INVEmpireMobileError *error) {
                                                                       [self handlePagedResponse:error];
                                                                   }];
}
@end
