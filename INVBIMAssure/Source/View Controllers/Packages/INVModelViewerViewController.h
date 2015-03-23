//
//  GameViewController.h
//  INVModelViewerGLES
//
//  Created by Richard Ross on 11/19/14.
//  Copyright (c) 2014 Invicara. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GLKit;

@interface INVModelViewerViewController : GLKViewController

@property (nonatomic, strong) NSNumber *fileVersionId;
@property (nonatomic, strong) NSNumber *modelId;

- (void)highlightElement:(NSString *)elementId;

@end
