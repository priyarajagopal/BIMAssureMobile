//
//  INVCustomCollectionView.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/28/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVCustomCollectionView.h"
#import "INVRuntimeUtils.h"

@import ObjectiveC.runtime;

static void *noContentKey = &noContentKey;
static void *fontSizeKey = &fontSizeKey;

static void (*oldDrawRectImp)(id self, SEL _cmd, CGRect rect);
static void (*oldReloadDataImp)(id self, SEL _cmd);

@implementation UICollectionView (INVCustomCollectionView)

- (NSString *)noContentText
{
    return objc_getAssociatedObject(self, noContentKey);
}

- (void)setNoContentText:(NSString *)noContentText
{
    objc_setAssociatedObject(self, noContentKey, noContentText, OBJC_ASSOCIATION_COPY);
}

- (int)fontSize
{
    id fontSize = objc_getAssociatedObject(self, fontSizeKey);
    if (fontSize == nil)
        return 30;

    return [fontSize intValue];
}

- (void)setFontSize:(int)fontSize
{
    objc_setAssociatedObject(self, fontSizeKey, @(fontSize), OBJC_ASSOCIATION_RETAIN);
}

- (void)_reloadData
{
    oldReloadDataImp(self, _cmd);

    [self setNeedsDisplay];
}

- (BOOL)_hasContent
{
    for (NSInteger index = 0; index < [self numberOfSections]; index++) {
        if ([self numberOfItemsInSection:index]) {
            return YES;
        }

#if !TARGET_INTERFACE_BUILDER
        if ([self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
            if ([self.dataSource collectionView:self
                    viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                          atIndexPath:[NSIndexPath indexPathForItem:0 inSection:index]]) {
                return YES;
            }

            if ([self.dataSource collectionView:self
                    viewForSupplementaryElementOfKind:UICollectionElementKindSectionFooter
                                          atIndexPath:[NSIndexPath indexPathForItem:0 inSection:index]]) {
                return YES;
            }
        }
#endif
    }

    return NO;
}

- (void)_drawRect:(CGRect)rect
{
    oldDrawRectImp(self, _cmd, rect);

    if (self.noContentText && ![self _hasContent]) {
        NSDictionary *textAttributes = @{
            NSForegroundColorAttributeName : [self tintColor],
            NSFontAttributeName : [UIFont systemFontOfSize:self.fontSize]
        };

        CGSize size = [self.noContentText sizeWithAttributes:textAttributes];
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

        center.x -= (size.width / 2);
        center.y -= (size.height / 2);

        [self.noContentText drawAtPoint:center withAttributes:textAttributes];
    }
}

@end

__attribute__((constructor)) static void UICollectionView_INVCustomCollectionView_Init()
{
    Class kls = [UICollectionView class];

    oldDrawRectImp = (void *) safeSwapMethods(kls, @selector(drawRect:), @selector(_drawRect:));
    oldReloadDataImp = (void *) safeSwapMethods(kls, @selector(reloadData), @selector(_reloadData));
}