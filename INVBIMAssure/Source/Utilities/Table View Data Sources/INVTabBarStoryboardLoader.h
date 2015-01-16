//
//  TabBarStoryboardHandler.h
//  TabBarMultipleViews
//
//  Created by Richard Ross on 1/16/15.
//  Copyright (c) 2015 Invicara. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

IB_DESIGNABLE
@interface INVTabBarStoryboardLoader : NSObject

@property IBOutlet UITabBarController *tabBarController;

@property IBInspectable NSString *storyboard1, *storyboard2,
                                 *storyboard3, *storyboard4,
                                 *storyboard5;

@property IBInspectable NSString *identifier1, *identifier2,
                                 *identifier3, *identifier4,
                                 *identifier5;



@end
