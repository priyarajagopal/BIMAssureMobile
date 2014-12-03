//
//  INVSearchViewQuickSearchDataSource.h
//  INVBIMAssure
//
//  Created by Richard Ross on 12/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INVSearchView.h"

@interface INVSearchViewQuickSearchDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>

-(id) initWithSearchView:(INVSearchView *) searchView;

@property INVSearchView *searchView;

-(void) reloadData;

@end
