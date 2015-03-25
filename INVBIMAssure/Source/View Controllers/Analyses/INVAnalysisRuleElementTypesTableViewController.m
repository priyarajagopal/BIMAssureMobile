//
//  INVAnalysisRuleElementTypes.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/24/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVAnalysisRuleElementTypesTableViewController.h"
#import "INVBlockUtils.h"

#import <AWPagedArray/AWPagedArray.h>

@interface INVAnalysisRuleElementTypesTableViewController () <AWPagedArrayDelegate>

@property NSString *originalSelection;

@property AWPagedArray *pagedArray;
@property NSArray *baTypes;

@end

@implementation INVAnalysisRuleElementTypesTableViewController

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

                                                       self.pagedArray.totalCount = [result[@"totalcount"] integerValue];

                                                       [self.pagedArray setObjects:result[@"list"] forPage:pageIndex];
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
    self.currentSelection = self.originalSelection;

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
    }

    id result = self.baTypes[indexPath.row];
    if ([result isKindOfClass:[NSNull class]]) {
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        cell.textLabel.text = result[@"name"];
        cell.accessoryType = UITableViewCellAccessoryNone;

        if ([result[@"code"] isEqualToString:self.currentSelection]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id result = self.baTypes[indexPath.row];

    self.currentSelection = result[@"code"];

    [self.tableView reloadData];
}

#pragma mark - AWPagedArrayDelegate

- (void)pagedArray:(AWPagedArray *)pagedArray willAccessIndex:(NSUInteger)index returnObject:(__autoreleasing id *)returnObject
{
    if ([*returnObject isKindOfClass:[NSNull class]]) {
        [self loadPageAtIndex:[pagedArray pageForIndex:index]];
    }
}

@end
