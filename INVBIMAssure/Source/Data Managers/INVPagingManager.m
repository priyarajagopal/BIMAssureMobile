//
//  INVPagingManager.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVPagingManager.h"
#import "INVPagingManager+Private.h"

const NSInteger DEFAULT_PAGESIZE = 20;

@implementation INVPagingManager

-(instancetype) initWithPageSize:(NSInteger)pageSize delegate:(id<INVPagingManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.currOffset = 0;
        self.pageSize = pageSize;
        self.globalDataManager = [INVGlobalDataManager sharedInstance];
        self.delegate = delegate;
    }
    return self;
}

-(id)init {
    return [self initWithPageSize:DEFAULT_PAGESIZE delegate:nil];
}

-(void)resetOffset {
    self.currOffset = 0;
}


@end
