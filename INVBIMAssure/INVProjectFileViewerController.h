//
//  INVProjectFileViewerController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/12/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INVProjectFileViewerController : UIViewController
@property (nonatomic,strong)NSNumber* fileVersionId;
@property (nonatomic,strong)NSNumber* modelId;
@property (weak, nonatomic) IBOutlet UIView *webviewContainerView;
- (IBAction)onHomeSelected:(id)sender;
- (IBAction)onToggleSelectionSelected:(id)sender;
- (IBAction)onEmphasizeSelected:(id)sender;
- (IBAction)onGlassViewSelected:(id)sender;
- (IBAction)onShadowSelected:(id)sender;

@end
