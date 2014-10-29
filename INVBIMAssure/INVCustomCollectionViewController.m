//
//  INVCustomCollectionViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomCollectionViewController.h"


@interface INVCustomCollectionViewController ()<UICollectionViewDelegate>
@property (nonatomic,readwrite)INVGlobalDataManager* globalDataManager;

@end

@implementation INVCustomCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.globalDataManager = [INVGlobalDataManager sharedInstance];
    [self customizeLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateLayout) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)customizeLayout {
    UICollectionViewFlowLayout* currLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    currLayout.minimumLineSpacing = 10;
    currLayout.minimumInteritemSpacing = 10;
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self invalidateLayout];
}
 
/*
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}
 */
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark <UICollectionViewDelegate>
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

#pragma mark - helpers
-(void)invalidateLayout {
    [self.collectionView.collectionViewLayout invalidateLayout];
}


@end
