//
//  INVSearchViewQuickSearchDataSource.m
//  INVBIMAssure
//
//  Created by Richard Ross on 12/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#define SECTION_TAGS 0
#define SECTION_SEARCH_HISTORY 1
#define SECTION_COUNT 2

#import "INVSearchViewQuickSearchDataSource.h"
#import "INVSearchViewPrivate.h"

@implementation INVSearchViewQuickSearchDataSource

-(id) initWithSearchView:(INVSearchView *)searchView {
    if (self = [super init]) {
        self.searchView = searchView;
    }
    
    return self;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    // TODO - hide sections if they have no data?
    return SECTION_COUNT;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTION_TAGS) {
        // TODO - Filter based on search text
        return self.searchView.allTags.count;
    }
    
    if (section == SECTION_SEARCH_HISTORY) {
        return self.searchView.searchHistory.count;
    }
    
    return 0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    static NSString *titles[] = {
        @"Tags",
        @"Search History"
    };
    
    return titles[section];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BasicCell"];
    }
    
    if (indexPath.section == SECTION_TAGS) {
        NSString *tag = self.searchView.allTags[indexPath.row];
        
        cell.textLabel.text = tag;
        cell.tintColor = [UIColor blueColor];
        
        cell.accessoryType = [self.searchView.selectedTags containsObject:tag] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    if (indexPath.section == SECTION_SEARCH_HISTORY) {
        NSString *history = self.searchView.searchHistory[indexPath.row];
        
        cell.textLabel.text = history;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_TAGS) {
        NSString *tag = self.searchView.allTags[indexPath.row];
        [self.searchView _onTagToggled:tag];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    if (indexPath.section == SECTION_SEARCH_HISTORY) {
        // TODO - Replace current search
        NSString *historyEntry = self.searchView.searchHistory[indexPath.row];
        [self.searchView setSearchText:historyEntry];
        
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:YES];
    }
}

@end