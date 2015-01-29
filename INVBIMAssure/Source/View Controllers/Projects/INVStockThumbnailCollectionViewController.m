//
//  INVStockThumbnailCollectionViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/6/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVStockThumbnailCollectionViewController.h"
#import "INVStockThumbnailCollectionViewCell.h"
#import "UIImage+INVCustomizations.h"

@interface INVStockThumbnailCollectionViewController ()

@property NSArray *stockImages;

@end

@implementation INVStockThumbnailCollectionViewController

- (id)init
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];

    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(150, 150);
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);

    if (self = [super initWithCollectionViewLayout:flowLayout]) {
        _stockImages = [UIImage imagesInFolderNamed:@"Stock Thumbnails"];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.backgroundColor = [UIColor whiteColor];

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([INVStockThumbnailCollectionViewCell class]) bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"thumbnailCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _stockImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    INVStockThumbnailCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
    cell.imageView.image = _stockImages[indexPath.row];

    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(stockThumbnailCollectionViewController:didSelectStockThumbnail:)]) {
        [self.delegate stockThumbnailCollectionViewController:self didSelectStockThumbnail:_stockImages[indexPath.row]];
    }
}

@end
