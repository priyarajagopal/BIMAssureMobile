//
//  INVMutableArrayTableViewDataSource.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//
#import "INVMutableArrayTableViewDataSource.h"

@interface INVMutableArrayTableViewDataSource ()

@property NSMutableArray *contents;

@end

@implementation INVMutableArrayTableViewDataSource

- (id)init
{
    if (self = [super init]) {
        _contents = [NSMutableArray new];
    }

    return self;
}

#pragma mark - NSArray Methods

- (NSUInteger)count
{
    return [_contents count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [_contents objectAtIndex:index];
}

#pragma mark - NSMutableArray Methods

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [_contents insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [_contents removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject
{
    [_contents addObject:anObject];
}

- (void)removeLastObject
{
    [_contents removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [_contents replaceObjectAtIndex:index withObject:anObject];
}

#pragma mark - UITableViewDataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.tableViewCellIdentifier];
    cell.textLabel.text = [self[indexPath.row] description];

    return cell;
}

- (BOOL)isEqual:(id)object
{
    // Use pointer comparison here. If we are placed into a set by UINib,
    // we end up in a strange state where the same datasource gets attached
    // to both table views!! and the other gets deleted. Seems like a NIB bug to me personally.
    return self == object;
}

@end
