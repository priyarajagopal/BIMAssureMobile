//
//  INVCustomTableView.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/28/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "UITableView+INVCustomTableView.h"
#import "INVRuntimeUtils.h"

#define INITIAL_LOAD_NOT_STARTED 0
#define INITIAL_LOAD_STARTED 1
#define INITIAL_LOAD_FINISHED 2

@import ObjectiveC.runtime;
@import QuartzCore;

static void *initialLoadKey = &initialLoadKey;
static void *noContentKey = &noContentKey;
static void *fontSizeKey = &fontSizeKey;
static void *textLayerKey = &textLayerKey;

static void (*oldReloadDataImp)(id self, SEL _cmd);
static void (*oldLayoutSubviewsImp)(id self, SEL _cmd);

@implementation UITableView (INVCustomCollectionView)

- (int)_inv_isInitialLoad
{
    return [objc_getAssociatedObject(self, initialLoadKey) intValue];
}

- (void)set_inv_isInitialLoad:(int)initial
{
    objc_setAssociatedObject(self, initialLoadKey, @(initial), OBJC_ASSOCIATION_RETAIN);
}

- (CATextLayer *)_inv_textLayer
{
    CATextLayer *results = objc_getAssociatedObject(self, textLayerKey);
    if (results == nil) {
        results = [CATextLayer new];
        results.anchorPoint = CGPointMake(0.5, 0.5);

        return (self._inv_textLayer = results);
    }

    return results;
}

- (void)set_inv_textLayer:(CATextLayer *)textLayer
{
    objc_setAssociatedObject(self, textLayerKey, textLayer, OBJC_ASSOCIATION_RETAIN);

    [self _inv_updateLayer];
}

- (NSString *)noContentText
{
    return objc_getAssociatedObject(self, noContentKey);
}

- (void)setNoContentText:(NSString *)noContentText
{
    objc_setAssociatedObject(self, noContentKey, noContentText, OBJC_ASSOCIATION_COPY);

    [self _inv_updateLayer];
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

    [self _inv_updateLayer];
}

- (void)_inv_reloadData
{
    oldReloadDataImp(self, _cmd);

    [self _inv_updateLayer];

    if ([self _inv_isInitialLoad] == INITIAL_LOAD_NOT_STARTED) {
        [self set_inv_isInitialLoad:INITIAL_LOAD_STARTED];
    }
    else if ([self _inv_isInitialLoad] == INITIAL_LOAD_STARTED) {
        [self set_inv_isInitialLoad:INITIAL_LOAD_FINISHED];
    }
}

- (void)_inv_layoutSubviews
{
    oldLayoutSubviewsImp(self, _cmd);

    [self _inv_updateLayer];
}

- (BOOL)_inv_hasContent
{
    for (NSInteger index = 0; index < [self.dataSource numberOfSectionsInTableView:self]; index++) {
        if ([self.dataSource tableView:self numberOfRowsInSection:index]) {
            return YES;
        }

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
    }

    return NO;
}

- (void)_inv_updateLayer
{
    if (self.noContentText && ![self _inv_hasContent] && [self _inv_isInitialLoad] == INITIAL_LOAD_FINISHED) {
        NSAttributedString *attributedString =
            [[NSAttributedString alloc] initWithString:self.noContentText
                                            attributes:@{
                                                NSForegroundColorAttributeName : [self tintColor],
                                                NSFontAttributeName : [UIFont systemFontOfSize:self.fontSize]
                                            }];

        self._inv_textLayer.string = attributedString;
        self._inv_textLayer.bounds = (CGRect){CGPointZero, [attributedString size]};
        self._inv_textLayer.position = CGPointMake(CGRectGetMidX(self.layer.bounds), CGRectGetMidY(self.layer.bounds));

        [self.layer insertSublayer:self._inv_textLayer atIndex:0];
    }
    else {
        [self._inv_textLayer removeFromSuperlayer];
    }
}

@end

__attribute__((constructor)) static void UICollectionView_INVCustomCollectionView_Init()
{
    Class kls = [UITableView class];

    oldReloadDataImp = (void *) safeSwapMethods(kls, @selector(reloadData), @selector(_inv_reloadData));
    oldLayoutSubviewsImp = (void *) safeSwapMethods(kls, @selector(layoutSubviews), @selector(_inv_layoutSubviews));
}