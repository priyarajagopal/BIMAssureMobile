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
        if (self.delegate && [self.delegate respondsToSelector:@selector(onStartedFetchingData)]) {
            [self.delegate onStartedFetchingData];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onFetchedDataAtOffset:pageSize:withError:)]) {
            [self.delegate onFetchedDataAtOffset:self.currOffset pageSize:self.pageSize withError:error];
        }
        
        self.currOffset+= self.pageSize;
        
    }];
}
@end
