//
//  INVCustomTableView.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/28/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomTableView.h"

@implementation INVCustomTableView

+(instancetype) allocWithZone:(struct _NSZone *)zone {
    INVCustomTableView *result = [super allocWithZone:zone];
    result.fontSize = 30;
    
    return result;
}

-(void) reloadData {
    [super reloadData];
    
    [self setNeedsDisplay];
}

-(BOOL) hasContent {
    for (NSInteger index = 0; index < [self numberOfSections]; index++) {
        if ([self numberOfRowsInSection:index]) {
            return YES;
        }
        
        // Sending any messages to the datasource in While in IB will cause it to crash.
#if !TARGET_INTERFACE_BUILDER
        if ([self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)] &&
            [self.dataSource tableView:self titleForHeaderInSection:index] && [self sectionHeaderHeight]) {
            return YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)] &&
            [self.delegate tableView:self viewForHeaderInSection:index]) {
            return YES;
        }
        
        if ([self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)] &&
            [self.dataSource tableView:self titleForFooterInSection:index] && [self sectionFooterHeight]) {
            return YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)] &&
            [self.delegate tableView:self viewForFooterInSection:index]) {
            return YES;
        }
#endif
    }
    
    return NO;
}

-(void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.noContentText && ![self hasContent]) {
        NSDictionary *textAttributes = @{
            NSForegroundColorAttributeName: [self tintColor],
            NSFontAttributeName: [UIFont systemFontOfSize:self.fontSize]
        };
        
        CGSize size = [self.noContentText sizeWithAttributes:textAttributes];
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        center.x -= (size.width / 2);
        center.y -= (size.height / 2);
        
        [self.noContentText drawAtPoint:center withAttributes:textAttributes];
    }
}

@end
