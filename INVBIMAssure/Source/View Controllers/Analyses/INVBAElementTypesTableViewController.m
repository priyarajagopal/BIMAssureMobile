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

@property NSMutableSet *loadingPages;
@property AWPagedArray *pagedArray;
@property NSArray *baTypes;

@end

@implementation INVBAElementTypesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pagedArray = [[AWPagedArray alloc] initWithCount:0 objectsPerPage:50 initialPageIndex:0];
    self.pagedArray.delegate = self;

    self.baTypes = (NSArray *) self.pagedArray;
    self.loadingPages = [NSMutableSet new];

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

    if ([self.loadingPages containsObject:@(pageIndex)] || self.pagedArray.pages[@(pageIndex)] != nil)
        return;

    [self.loadingPages addObject:@(pageIndex)];
    dispatch_async(queue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        [self.globalDataManager.invServerClient
            fetchBATypesFromOffset:@(pageIndex * self.pagedArray.objectsPerPage)
                          withSize:@(self.pagedArray.objectsPerPage)
               withCompletionBlock:^(NSDictionary *result, INVEmpireMobileError *error) {
                   if (self.refreshControl.isRefreshing) {
                       [self.refreshControl endRefreshing];
                   }

                   NSUInteger oldCount = self.pagedArray.totalCount;
                   if (oldCount != [result[@"total"] integerValue]) {
                       self.pagedArray.totalCount = [result[@"total"] integerValue];
                       [self.tableView reloadData];
                   }

                   NSMutableArray *hits = [[result valueForKeyPath:@"hits.fields"] mutableCopy];
                   [hits enumerateObjectsWithOptions:NSEnumerationConcurrent
                                          usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                              NSDictionary *replacement = @{
                                                  @"code" : [obj[@"code"] firstObject],
                                                  @"name" : [obj[@"name"] firstObject]
                                              };

                                              [hits replaceObjectAtIndex:idx withObject:replacement];
                                          }];

                   [self.pagedArray setObjects:hits forPage:pageIndex];

                   [self.tableView beginUpdates];
                   [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows
                                         withRowAnimation:UITableViewRowAnimationNone];
                   [self.tableView endUpdates];

                   dispatch_semaphore_signal(semaphore);
               }];

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        [self.loadingPages removeObject:@(pageIndex)];
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
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self _deselectedImage]];
    }

    id result = self.baTypes[indexPath.row];
    if ([result isKindOfClass:[NSNull class]]) {
        cell.textLabel.text = @"";
        [(UIImageView *) cell.accessoryView setImage:[self _deselectedImage]];
    }
    else {
        cell.textLabel.text = result[@"name"];

        if ([result[@"code"] isEqualToString:self.currentSelection]) {
            [(UIImageView *) cell.accessoryView setImage:[self _selectedImage]];
        }
        else {
            [(UIImageView *) cell.accessoryView setImage:[self _deselectedImage]];
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id result = self.baTypes[indexPath.row];

    self.currentSelection = result[@"code"];

    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                          withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - AWPagedArrayDelegate

- (void)pagedArray:(AWPagedArray *)pagedArray willAccessIndex:(NSUInteger)index returnObject:(__autoreleasing id *)returnObject
{
    if ([*returnObject isKindOfClass:[NSNull class]]) {
        [self loadPageAtIndex:[pagedArray pageForIndex:index]];
    }
    else {
        [self loadPageAtIndex:[pagedArray pageForIndex:index + 1]];
    }
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
