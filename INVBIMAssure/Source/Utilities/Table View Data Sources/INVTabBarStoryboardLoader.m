//
//  INVTabBarStoryboardHandler.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/16/15.
//  Copyright (c) 2015 Invicara. All rights reserved.
//

#import "INVTabBarStoryboardLoader.h"


@implementation INVTabBarStoryboardLoader

-(void) awakeFromNib {
    NSArray *storyboardNames = @[
        self.storyboard1 ?: [NSNull null],
        self.storyboard2 ?: [NSNull null],
        self.storyboard3 ?: [NSNull null],
        self.storyboard4 ?: [NSNull null],
        self.storyboard5 ?: [NSNull null]
    ];
    
    NSArray *storyboardViewControllerIdentifiers = @[
        self.identifier1 ?: [NSNull null],
        self.identifier2 ?: [NSNull null],
        self.identifier3 ?: [NSNull null],
        self.identifier4 ?: [NSNull null],
        self.identifier5 ?: [NSNull null],
    ];
    
    NSMutableArray *viewControllers = [NSMutableArray new];
    
    for (NSInteger index = 0; index < storyboardNames.count; index++) {
        NSString *storyboardName = storyboardNames[index];
        NSString *storyboardIdentifier = storyboardViewControllerIdentifiers[index];
        
        if ([storyboardName isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
        
        if ([storyboardIdentifier isKindOfClass:[NSNull class]]) {
            [viewControllers addObject:[storyboard instantiateInitialViewController]];
        } else {
            [viewControllers addObject:[storyboard instantiateViewControllerWithIdentifier:storyboardIdentifier]];
        }
    }
    
    self.tabBarController.viewControllers = [viewControllers copy];
}

@end
