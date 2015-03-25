//
//  INVPagingManager+PackageMasterListing.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVPagingManager+PackageMasterListing.h"
#import "INVPagingManager+Private.h"

@implementation INVPagingManager (PackageMasterListing)
- (void)fetchPackageMastersFromCurrentOffsetForProject:(NSNumber *)projectId
{
    [self.globalDataManager.invServerClient getAllPkgMastersForProject:projectId
                                                            WithOffset:@(self.currOffset)
                                                              pageSize:@(self.pageSize)
                                                   WithCompletionBlock:^(INVEmpireMobileError *error) {
                                                       [self handlePagedResponse:error];
                                                   }];
}
@end
