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

    self.originalUnit = self.currentUnit;

    [self fetchListOfUnits];
}

#pragma mark - Content Managment

- (void)fetchListOfUnits
{
    [self.globalDataManager.invServerClient
        fetchSupportedUnitsForSignedInAccountWithCompletionBlock:^(INVBAUnitArray units, INVEmpireMobileError *error) {
            INV_ALWAYS:
                if (self.refreshControl.isRefreshing) {
                    [self.refreshControl endRefreshing];
                }

            INV_SUCCESS:
                self.allUnits = units;
                [self filterListOfUnits];

            INV_ERROR:
                INVLogError(@"%@", error);
        }];

    if (self.refreshControl.isRefreshing)
        [self.refreshControl endRefreshing];

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
    self.currentUnit = self.originalUnit ?: @"";

    [self performSegueWithIdentifier:@"unwind" sender:nil];
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
        UIFont* font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.font = font;
        cell.detailTextLabel.font = font;
        
    }

    id unit = self.filteredUnits[indexPath.row];
      cell.textLabel.text = unit[@"display"];
    
    cell.detailTextLabel.text  = unit[@"unit"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([self.currentUnit isEqualToString:unit[@"unit"]]) {
        [(UIImageView *) cell.accessoryView setImage:[self _selectedImage]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.currentUnit = self.filteredUnits[indexPath.row][@"unit"];

    [tableView reloadRowsAtIndexPaths:tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
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
