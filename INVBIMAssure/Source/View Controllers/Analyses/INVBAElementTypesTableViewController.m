//
//  INVAnalysisRuleElementTypes.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/24/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVBAElementTypesTableViewController.h"
#import "INVBlockUtils.h"

#import <AWPagedArray/AWPagedArray.h>

@interface INVBAElementTypesTableViewController () <AWPagedArrayDelegate>

@property NSString *originalSelection;

@property AWPagedArray *pagedArray;
@property NSArray *baTypes;

@end

@implementation INVBAElementTypesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pagedArray = [[AWPagedArray alloc] initWithCount:0 objectsPerPage:1000 initialPageIndex:0];
    self.pagedArray.delegate = self;

    self.baTypes = (NSArray *) self.pagedArray;

    [self loadPageAtIndex:0];

    self.originalSelection = self.currentSelection;
}

#pragma mark - Content Management

- (void)loadPageAtIndex:(NSUInteger)pageIndex
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.invicara.analysis-rule-types-queue", DISPATCH_QUEUE_SERIAL);
    });

    dispatch_async(queue, ^{
        if (self.pagedArray.totalCount && self.pagedArray.pages[@(pageIndex)]) {
            return;
        }

        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        [self.globalDataManager.invServerClient fetchBATypesFromOffset:@(pageIndex * self.pagedArray.objectsPerPage)
                                                              withSize:@(self.pagedArray.objectsPerPage)
                                                   withCompletionBlock:^(NSDictionary *result, INVEmpireMobileError *error) {
                                                       [self.refreshControl endRefreshing];

                                                       self.pagedArray.totalCount = [result[@"total"] integerValue];

                                                       [self.pagedArray setObjects:result[@"hits"] forPage:pageIndex];
                                                       [self.tableView reloadData];

                                                       dispatch_semaphore_signal(semaphore);
                                                   }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark - IBActions

- (void)onRefreshControlSelected:(id)sender
{
    [self.pagedArray invalidateContents];
    self.pagedArray.totalCount = 0;

    [self loadPageAtIndex:0];

    [self.tableView reloadData];
}

- (IBAction)cancel:(id)sender
{
    self.currentSelection = self.originalSelection ? self.originalSelection : @"";

    [self performSegueWithIdentifier:@"unwind" sender:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.baTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ruleElementType"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ruleElementType"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    id result = self.baTypes[indexPath.row];
    if ([result isKindOfClass:[NSNull class]]) {
        cell.textLabel.text = @"";
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self _deselectedImage]];
    }
    else {
        cell.textLabel.text = result[@"_id"];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self _deselectedImage]];

        if ([result[@"_id"] isEqualToString:self.currentSelection]) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[self _selectedImage]];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id result = self.baTypes[indexPath.row];

    self.currentSelection = result[@"_id"];

    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - AWPagedArrayDelegate

- (void)pagedArray:(AWPagedArray *)pagedArray willAccessIndex:(NSUInteger)index returnObject:(__autoreleasing id *)returnObject
{
    if ([*returnObject isKindOfClass:[NSNull class]]) {
        [self loadPageAtIndex:[pagedArray pageForIndex:index]];
    }
}

#pragma mark - helpers

- (UIImage *)_selectedImage
{
    FAKFontAwesome *selectedIcon = [FAKFontAwesome checkCircleIconWithSize:30];
    [selectedIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
    return [selectedIcon imageWithSize:CGSizeMake(30, 30)];
}

- (UIImage *)_deselectedImage
{
    FAKFontAwesome *deselectedIcon = [FAKFontAwesome circleOIconWithSize:30];
    [deselectedIcon setAttributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];

    return [deselectedIcon imageWithSize:CGSizeMake(30, 30)];
}

@end
