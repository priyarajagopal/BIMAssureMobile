//
//  INVPagingManager+Private.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVPagingManager()
@property (nonatomic,assign) NSInteger currOffset;
@property (nonatomic,assign) NSInteger pageSize;
@property (nonatomic,strong) INVGlobalDataManager* globalDataManager;
-(void)handlePagedResponse:(INVEmpireMobileError*)error;

@end
