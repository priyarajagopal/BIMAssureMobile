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

#define MAX_TAG_RESULTS INT_MAX

#import "INVSearchViewQuickSearchDataSource.h"
#import "INVSearchViewPrivate.h"

@interface INVSearchViewQuickSearchDataSource ()

@property NSArray *topTags;

@end

@implementation INVSearchViewQuickSearchDataSource

- (id)initWithSearchView:(INVSearchView *)searchView
{
    if (self = [super init]) {
        self.searchView = searchView;
    }

    return self;
}

int levenshteinDistance(const char *s, size_t len_s, const char *t, int len_t)
{
    if (len_s > 5)
        len_s = 5;
    if (len_t > 5)
        len_t = 5;

    if (len_s == 0)
        return len_t;
    if (len_t == 0)
        return len_s;

    int cost = 0;

    if (s[len_s - 1] != t[len_t - 1]) {
        cost = 1;
    }

    // See which of the three possible paths is cheapest
    int costA = levenshteinDistance(s, len_s - 1, t, len_t) + 1;
    int costB = levenshteinDistance(s, len_s, t, len_t - 1) + 1;
    int costC = levenshteinDistance(s, len_s - 1, t, len_t - 1) + cost;

    return MIN(MIN(costA, costB), costC);
}

- (void)reloadData
{
    NSString *currentFilter = self.searchView.searchText;
    NSMutableOrderedSet *filteredTags = [self.searchView.allTags mutableCopy];

    const char *currentFilterUTF = [currentFilter UTF8String];

    // Order by 'closeness' to filter (using levenshtein algorithm)
    [filteredTags sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        const char *obj1UTF = [obj1 UTF8String];
        const char *obj2UTF = [obj2 UTF8String];

        int obj1dist = levenshteinDistance(obj1UTF, [obj1 length], currentFilterUTF, [currentFilter length]);
        int obj2dist = levenshteinDistance(obj2UTF, [obj2 length], currentFilterUTF, [currentFilter length]);

        return (obj1dist - obj2dist);
    }];

    _topTags = [filteredTags
        objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(filteredTags.count, MAX_TAG_RESULTS))]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // TODO - hide sections if they have no data?
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_TAGS) {
        // TODO - Filter based on search text
        return _topTags.count;
    }

    if (section == SECTION_SEARCH_HISTORY) {
        return self.searchView.searchHistory.count;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    static NSString *titles[] = { @"Tags", @"Search History" };

    return titles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BasicCell"];
    }

    if (indexPath.section == SECTION_TAGS) {
        NSString *tag = _topTags[indexPath.row];

        cell.textLabel.text = tag;
        cell.tintColor = [UIColor blueColor];

        cell.accessoryType = [self.searchView.selectedTags containsObject:tag] ? UITableViewCellAccessoryCheckmark
                                                                               : UITableViewCellAccessoryNone;
    }

    if (indexPath.section == SECTION_SEARCH_HISTORY) {
        NSString *history = self.searchView.searchHistory[indexPath.row];

        cell.textLabel.text = history;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_TAGS) {
        NSString *tag = _topTags[indexPath.row];
        [self.searchView _onTagToggled:tag];

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    if (indexPath.section == SECTION_SEARCH_HISTORY) {
        // TODO - Replace current search
        NSString *historyEntry = self.searchView.searchHistory[indexPath.row];
        [self.searchView setSearchText:historyEntry];

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor lightGrayColor];
}

@end