//
//  GameViewController.m
//  INVModelViewerGLES
//
//  Created by Richard Ross on 11/19/14.
//  Copyright (c) 2014 Invicara. All rights reserved.
//

#import "INVModelViewerViewController.h"

#import "INVJSONCTMManager.h"

@import OpenCTM;
@import SceneKit;

@interface INVModelViewerViewController () {
    SCNScene *_scene;
}

@end

@implementation INVModelViewerViewController

-(void) setupScene {
    _scene = [SCNScene scene];
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.zFar = 1000000;
    
    [_scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0,0, 100);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.light.color = [UIColor whiteColor];
    lightNode.light.castsShadow = YES;
    lightNode.light.shadowColor = [UIColor blackColor];
    
    lightNode.position = SCNVector3Make(0, -100, 100);
    
    [_scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    
    [_scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = _scene;
    scnView.jitteringEnabled = NO;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [UIColor whiteColor];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self setupScene];
    
    // Load in the model
    
}

@end
