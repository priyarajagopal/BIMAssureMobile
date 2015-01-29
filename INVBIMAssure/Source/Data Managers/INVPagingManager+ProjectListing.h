//
//  INVPagingManager+ProjectListing.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVPagingManager.h"

@interface INVPagingManager (ProjectListing)
- (void)fetchProjectsFromCurrentOffset;
@end
