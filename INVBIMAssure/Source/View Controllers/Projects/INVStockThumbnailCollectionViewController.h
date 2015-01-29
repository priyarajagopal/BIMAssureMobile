//
//  INVStockThumbnailCollectionViewController.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INVStockThumbnailCollectionViewController;
@protocol INVStockThumbnailCollectionViewControllerDelegate<NSObject>

@optional
- (void)stockThumbnailCollectionViewController:(INVStockThumbnailCollectionViewController *)controller
                       didSelectStockThumbnail:(UIImage *)image;

@end

@interface INVStockThumbnailCollectionViewController : UICollectionViewController

@property (weak, nonatomic) id<INVStockThumbnailCollectionViewControllerDelegate> delegate;

@end
