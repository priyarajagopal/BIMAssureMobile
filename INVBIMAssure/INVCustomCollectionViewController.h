//
//  INVCustomCollectionViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVCustomCollectionViewController : UICollectionViewController
@property (nonatomic,readonly)INVGlobalDataManager* globalDataManager;
@property (nonatomic,strong)MBProgressHUD* hud;
@end
