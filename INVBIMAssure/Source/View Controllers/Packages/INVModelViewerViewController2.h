//
//  INVModelViewerViewController2.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 5/10/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface INVModelViewerViewController2 : GLKViewController
@property (nonatomic, strong) NSNumber *fileVersionId;
@property (nonatomic, strong) NSNumber *modelId;

- (IBAction)goHome:(id)sender;
- (IBAction)toggleShadow:(id)sender;
- (IBAction)toggleGlass:(id)sender;
- (IBAction)toggleVisible:(id)sender;
- (IBAction)highlightElement:(NSString *)elementId;

@end
