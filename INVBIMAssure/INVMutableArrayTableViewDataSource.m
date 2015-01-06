//
//  INVMutableArrayTableViewDataSource.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

// NOTE: Purposefully not importing header here.
// This is a hack to make our implementation actually subclass NSObject, instead of NSMutableArray.
// #import "INVMutableArrayTableViewDataSource.h"

// By making our object actually subclass NSObject, we can use the forwardingTargetForSelector:
// method to automatically implement all the NSMutableArray methods.
@interface INVMutableArrayTableViewDataSource : NSObject<UITableViewDataSource>

@property NSString *tableViewCellIdentifier;

@end

@implementation INVMutableArrayTableViewDataSource {
    NSMutableArray *_array;
}

-(id) init {
    if (self = [super init]) {
        _array = [NSMutableArray new];
    }
    
    return self;
}

/*
-(id) forwardingTargetForSelector:(SEL)aSelector {
    return _array;
}
 */

-(NSMethodSignature *) methodSignatureForSelector:(SEL)aSelector {
    return [super methodSignatureForSelector:aSelector] ?: [_array methodSignatureForSelector:aSelector];
}

-(void) forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:_array];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.tableViewCellIdentifier];
    cell.textLabel.text = [_array[indexPath.row] description];
    
    return cell;
}

-(NSUInteger) hash {
    return [_array hash];
}

-(NSString *) description {
    return [_array description];
}

-(NSString *) debugDescription {
    return [_array debugDescription];
}

@end
