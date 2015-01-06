//
//  INVMutableArrayTableViewDataSource.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVMutableArrayTableViewDataSource : NSMutableArray<UITableViewDataSource>

@property NSString *tableViewCellIdentifier;

@end
