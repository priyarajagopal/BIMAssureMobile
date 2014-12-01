//
//  INVSearchViewPrivate.h
//  INVBIMAssure
//
//  Created by Richard Ross on 12/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVSearchView.h"

@interface INVSearchView(Private)

@property (nonatomic, readonly) id inputField;
@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, readonly) UIView *inputFieldContainer;
@property (nonatomic, readonly) UIButton *tagsButton;
@property (nonatomic, readonly) UIButton *saveButton;
@property (nonatomic, readonly) NSOrderedSet *allTags;

-(void) _showTagsDropdown:(id) sender;
-(void) _showQuickSearchDropdown:(id) sender;
-(void) _showSaveDialog:(id)sender;

-(void) _onTagToggled:(NSString *) tag;
-(void) _onTagAdded:(NSString *) tag;
-(void) _onTagRemoved:(NSString *) tag;

@end