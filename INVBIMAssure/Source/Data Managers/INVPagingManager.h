//
//  INVPagingManager.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/16/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol INVPagingManagerDelegate <NSObject>

-(void)onFetchedDataAtOffset:(NSInteger)offset pageSize:(NSInteger)size withError:(INVEmpireMobileError*)error;

@end

@interface INVPagingManager : NSObject
@property (nonatomic, weak) id<INVPagingManagerDelegate> delegate;

-(instancetype) initWithPageSize:(NSInteger)pageSize delegate:(id<INVPagingManagerDelegate>)delegate;
-(void)resetOffset;
@end
