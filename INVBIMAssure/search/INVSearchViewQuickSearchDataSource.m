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
    return SECTION_COUNT;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTION_TAGS) {
        // TODO - Filter based on search text
        return self.searchView.allTags.count;
    }
    
    if (section == SECTION_SEARCH_HISTORY) {
        return 0;
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
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // Tags
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.searchView _onTagToggled:cell.textLabel.text];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end