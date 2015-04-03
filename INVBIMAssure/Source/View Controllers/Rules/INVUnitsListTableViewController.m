//
//  INVUnitsListTableViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/27/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVUnitsListTableViewController.h"

@interface INVUnitsListTableViewController () <UISearchBarDelegate>

@property IBOutlet UIBarButtonItem *saveButtonItem;
@property IBOutlet UISearchBar *searchBar;

@property NSArray *allUnits;
@property NSArray *filteredUnits;

@property NSString *originalUnit;

@end

@implementation INVUnitsListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchBar.placeholder = NSLocalizedString(@"UNIT_SEARCH_PLACEHOLDER", nil);

    self.refreshControl = nil;
    self.originalUnit = self.currentUnit;

    if (![self.currentUnit isKindOfClass:[NSNull class]]) {
        self.searchBar.placeholder = self.currentUnit;
    }

    // NOTE: This is a private API that lets our search look nicer.
    // Check on every iOS release if this becomes public, and use that instead if possible.
    // [self.tableView _setPinsTableHeaderView:YES];
    [self.tableView setTableHeaderView:self.searchBar];

    [self fetchListOfUnits];
}

#pragma mark - Content Managment

- (void)fetchListOfUnits
{
    [self.globalDataManager.invServerClient
        fetchSupportedUnitsForSignedInAccountWithCompletionBlock:^(INVBAUnitArray units, INVEmpireMobileError *error) {
            INV_ALWAYS:
            INV_SUCCESS:
                self.allUnits = units;
                [self filterListOfUnits];

            INV_ERROR:
                INVLogError(@"%@", error);
        }];

    [self filterListOfUnits];
}

- (void)filterListOfUnits
{
    NSPredicate *predicate =
        [[NSPredicate predicateWithFormat:@"$search.length = 0 OR display CONTAINS[cd] $search OR unit CONTAINS[cd] $search"]
            predicateWithSubstitutionVariables:@{
                @"search" : self.searchBar.text
            }];

    self.filteredUnits = [self.allUnits filteredArrayUsingPredicate:predicate];

    [self.tableView reloadData];
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender
{
    self.currentUnit = nil;

    [self performSegueWithIdentifier:@"unwind" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"unwind"]) {
        if ([self.currentUnit length] == 0) {
            self.currentUnit = (NSString *) [NSNull null];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredUnits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"unitCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"unitCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIFont *font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.font = font;
        cell.detailTextLabel.font = font;
    }

    id unit = self.filteredUnits[indexPath.row];
    cell.textLabel.text = unit[@"display"];

    cell.detailTextLabel.text = unit[@"unit"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([self.currentUnit isEqual:unit[@"unit"]]) {
        [(UIImageView *) cell.accessoryView setImage:[self _selectedImage]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([self.filteredUnits[indexPath.row][@"unit"] isEqual:self.currentUnit]) {
        self.currentUnit = nil;
        self.searchBar.placeholder = NSLocalizedString(@"UNIT_SEARCH_PLACEHOLDER", nil);
    }
    else {
        self.currentUnit = self.filteredUnits[indexPath.row][@"unit"];
        self.searchBar.placeholder = self.currentUnit;
    }

    [tableView reloadRowsAtIndexPaths:tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.currentUnit = searchText;
    searchBar.placeholder = NSLocalizedString(@"UNIT_SEARCH_PLACEHOLDER", nil);

    [self filterListOfUnits];
}

#pragma mark - helpers

- (UIImage *)_selectedImage
{
    static UIImage *selectedImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FAKFontAwesome *selectedIcon = [FAKFontAwesome checkCircleIconWithSize:30];
        [selectedIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
        selectedImage = [selectedIcon imageWithSize:CGSizeMake(30, 30)];
    });

    return selectedImage;
}

- (UIImage *)_deselectedImage
{
    static UIImage *deselectedImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FAKFontAwesome *deselectedIcon = [FAKFontAwesome circleOIconWithSize:30];
        [deselectedIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];

        deselectedImage = [deselectedIcon imageWithSize:CGSizeMake(30, 30)];
    });

    return deselectedImage;
}

@end
