//
//  INVCustomCollectionView.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/28/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomCollectionView.h"

@implementation INVCustomCollectionView

+(instancetype) allocWithZone:(struct _NSZone *)zone {
    INVCustomCollectionView *result = [super allocWithZone:zone];
    result.fontSize = 30;
    
    return result;
}

-(void) reloadData {
    [super reloadData];
    
    [self setNeedsDisplay];
}

-(BOOL) hasContent {
    for (NSInteger index = 0; index < [self numberOfSections]; index++) {
        if ([self numberOfItemsInSection:index]) {
            return YES;
        }
        
#if !TARGET_INTERFACE_BUILDER
        if ([self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
            if ([self.dataSource collectionView:self viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                atIndexPath:[NSIndexPath indexPathForItem:0 inSection:index]]) {
                return YES;
            }
            
            if ([self.dataSource collectionView:self viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                    atIndexPath:[NSIndexPath indexPathForItem:0 inSection:index]]) {
                return YES;
            }
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
