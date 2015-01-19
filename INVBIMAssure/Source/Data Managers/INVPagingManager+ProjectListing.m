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

-(void)fetchProjectsFromCurrentOffset {
       
    [self.globalDataManager.invServerClient getAllProjectsForSignedInAccountWithOffset:@(self.currOffset) pageSize:@(self.pageSize) includeTotalCount:NO WithCompletionBlock:^(INVEmpireMobileError *error) {
        [self handlePagedResponse:error];
    }];
}
@end
