//
//  INVSearchView.h
//  INVSearchField
//
//  Created by Richard Ross on 11/25/14.
//  Copyright (c) 2014 Invicara. All rights reserved.
//

@import UIKit;

@class INVSearchView;

/**
 * INVSearchViewDataSource
 * The data source protocol for an INVSearchView
 */
@protocol INVSearchViewDataSource <NSObject>
@optional

/** The number of tags contained in this search view */
-(NSUInteger) numberOfTagsInSearchView:(INVSearchView *) searchView;

/** Gets a tag at a specified index */
-(NSString *) searchView:(INVSearchView *) searchView tagAtIndex:(NSUInteger) index;

/** Gets the state of the specified tag */
-(BOOL) searchView:(INVSearchView *) searchView isTagSelected:(NSString *) tag;

@end

/**
 * INVSearchViewDelegate
 * The delegate protocol for an INVSearchView
 */
@protocol INVSearchViewDelegate <NSObject>
@optional

/** Called when the search view's text changes */
-(void) searchView:(INVSearchView *) searchView onSearchTextChanged:(NSString *) searchText;

/** Called when the enter button is hit on the user's keyboard */
-(void) searchView:(INVSearchView *) searchView onSearchPerformed:(NSString *) searchText;

/** Called when a tag is selected by the user */
-(void) searchView:(INVSearchView *) searchView onTagAdded:(NSString *) tag;

/** Called when a tag is removed by the user */
-(void) searchView:(INVSearchView *) searchView onTagDeleted:(NSString *) tag;

@end

/**
 * INVSearchView
 * A UIView subclass which contains logic for a universal tagged search across the BIMAssure application.
 */
@interface INVSearchView : UIView

/** Gets the selected tags contained in this search view. They are ordered by their index in the data source. */
@property (readonly) NSOrderedSet *selectedTags;

/** Gets the current search text of this search view */
// TODO: Make this readrwrite?
@property (readonly) NSString *searchText;

/** Gets or sets the data source of the reciever */
@property IBOutlet id<INVSearchViewDataSource> dataSource;

/** Gets or sets the delegate of the reciever */
@property IBOutlet id<INVSearchViewDelegate> delegate;

/** Reloads the data of the reciever. Call this whenver the data source changes and not in a delegate callback. */
-(void) reloadData;

/** Programatically selects a tag */
-(void) selectTag:(NSString *) tag;

/** Programatically removes a tag */
-(void) removeTag:(NSString *) tag;

@end
