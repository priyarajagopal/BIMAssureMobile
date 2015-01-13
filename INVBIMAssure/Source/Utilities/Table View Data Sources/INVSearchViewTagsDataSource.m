//
//  INVSearchViewTagsDataSource.m
//  INVBIMAssure
//
//  Created by Richard Ross on 12/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVSearchViewTagsDataSource.h"
#import "INVSearchViewPrivate.h"

/** INVSearchViewTagsDataSource */
@implementation INVSearchViewTagsDataSource

-(id) initWithSearchView:(INVSearchView *)searchView {
    if (self = [super init]) {
        self.searchView = searchView;
    }
    
    return self;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchView.allTags.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basicCell"];
    }
    
    NSString *tag = self.searchView.allTags[indexPath.row];
    
    cell.textLabel.text = tag;
    cell.tintColor = [UIColor blueColor];
    cell.accessoryType =  [self.searchView.selectedTags containsObject:tag] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.searchView _onTagToggled:cell.textLabel.text];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end