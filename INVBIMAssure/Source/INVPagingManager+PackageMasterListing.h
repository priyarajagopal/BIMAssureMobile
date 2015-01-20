//
//  INVPagingManager+PackageMasterListing.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/19/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVPagingManager.h"

@interface INVPagingManager (PackageMasterListing)
-(void)fetchPackageMastersFromCurrentOffsetForProject:(NSNumber*)projectId;
@end
