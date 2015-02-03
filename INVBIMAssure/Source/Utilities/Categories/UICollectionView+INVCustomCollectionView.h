//
//  INVCustomCollectionView.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/28/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface UICollectionView (INVCustomCollectionView)

@property IBInspectable NSString *noContentText;
@property IBInspectable int fontSize;

@end
