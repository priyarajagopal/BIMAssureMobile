//
//  GameViewController.m
//  SceneKitTest
//
//  Created by Richard Ross on 12/1/14.
//  Copyright (c) 2014 Invicara. All rights reserved.
//

#import "GameViewController.h"
#import "INVJSONCTMManager.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create a new scene
    SCNScene *scene = [SCNScene scene];
    
    // SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.dae"];
    
    NSData *sampleHouse = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Hospital" ofType:@"json"]];
    INVJSONCTMManager *ctmManager = [[INVJSONCTMManager alloc] initWithJSON:sampleHouse];
    
    NSLog(@"%li", [[ctmManager allModels] count]);
    
    for (SCNNode *node in [ctmManager allModels]) {
        [scene.rootNode addChildNode:node];
    }
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.zFar = 1000000;
    
    [scene.rootNode addChildNode:cameraNode];
    
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
    
    
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    
    [scene.rootNode addChildNode:ambientLightNode];
    
    
    SCNNode *axisNode = [SCNNode node];
    SCNPlane *xAxisPlane = [SCNPlane planeWithWidth:1000 height:1];
    SCNPlane *yAxisPlane = [SCNPlane planeWithWidth:1 height:1000];
    SCNPlane *zAxisPlane = [SCNPlane planeWithWidth:1 height:1000];
    
    SCNNode *zAxisNode = [SCNNode nodeWithGeometry:zAxisPlane];
    zAxisNode.transform = SCNMatrix4MakeRotation(1.57079633, 0, 0, 1);
    
    [axisNode addChildNode:[SCNNode nodeWithGeometry:xAxisPlane]];
    [axisNode addChildNode:[SCNNode nodeWithGeometry:yAxisPlane]];
    [axisNode addChildNode:zAxisNode];
    
    [scene.rootNode addChildNode:axisNode];
    
    
    // retrieve the ship node
    // SCNNode *ship = [scene.rootNode childNodeWithName:@"ship" recursively:YES];
    
    // animate the 3d object
    // [ship runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    scnView.jitteringEnabled = NO;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;

    // configure the view
    scnView.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
