//
//  INVProjectFileViewerController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/12/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVProjectFileViewerController : UIViewController
@property (nonatomic,copy)NSNumber* fileVersionId;
@property (nonatomic,copy)NSNumber* modelId;
@property (weak, nonatomic) IBOutlet UIView *webviewContainerView;

- (IBAction)onHomeSelected:(id)sender;
- (IBAction)onToggleSelectionSelected:(id)sender;
- (IBAction)onEmphasizeSelected:(id)sender;
- (IBAction)onGlassViewSelected:(id)sender;
- (IBAction)onShadowSelected:(id)sender;

@end
