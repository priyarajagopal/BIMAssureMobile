//
//  GameViewController.m
//  INVModelViewerGLES
//
//  Created by Richard Ross on 11/19/14.
//  Copyright (c) 2014 Invicara. All rights reserved.
//

#import "INVModelViewerViewController.h"

#import "INVStreamBasedCTMParser.h"

@import OpenCTM;
@import SceneKit;

@interface INVModelViewerViewController ()<INVStreamBasedCTMParserDelegate> {
    SCNScene *_scene;
    SCNNode *_modelNode;
    
    INVStreamBasedCTMParser *_ctmParser;
}

@end

@implementation INVModelViewerViewController

-(void) awakeFromNib {
    self.hidesBottomBarWhenPushed = YES;
}

-(void) setupScene {
    _scene = [SCNScene scene];
    
    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    
    cameraNode.camera.yFov = 55;
    cameraNode.camera.zNear = 0.5;
    cameraNode.camera.zFar = 10000;
    
    [_scene.rootNode addChildNode:cameraNode];
    
    cameraNode.position = SCNVector3Make(0, 15, 250);
    
    
    
    // place the camera
    // cameraNode.position = SCNVector3Make(0, 0, 1000);
    
    _modelNode = [SCNNode node];
    _modelNode.eulerAngles = SCNVector3Make(-M_PI / 2, 0, 0);
    
    
    /*
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.light.color = [UIColor colorWithWhite:0.66274509803 alpha:1];
    lightNode.position = SCNVector3Make(100, -100, 0);
    
    [_modelNode addChildNode:lightNode];
    */
    
    [_scene.rootNode addChildNode:_modelNode];
    
    SCNVector3 lightPostions[6] = {
        {  1000,     0,     0 },
        {     0,  1000,     0 },
        {     0,     0,  1000 },
        { -1000,     0,     0 },
        {     0, -1000,     0 },
        {     0,     0, -1000 }
    };
    
    for (int i = 0; i < 3; i++) {
        // create and add a light to the scene
        SCNNode *lightNode = [SCNNode node];
        lightNode.light = [SCNLight light];
        lightNode.light.type = SCNLightTypeOmni;
        lightNode.light.color = [UIColor colorWithWhite:0.5 alpha:1];
        
        lightNode.position = lightPostions[i];
        
        [_scene.rootNode addChildNode:lightNode];
    }
    
    /*
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    
    [_scene.rootNode addChildNode:ambientLightNode];
    */
     
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = _scene;
    scnView.antialiasingMode = SCNAntialiasingModeMultisampling2X;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [UIColor whiteColor];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupScene];
    
    NSArray *urls = @[
                      /*
        @"http://richards-macbook-pro.local/progressive/test0-1.json",
        @"http://richards-macbook-pro.local/progressive/test1-2.json",
        @"http://richards-macbook-pro.local/progressive/test2-3.json",
        @"http://richards-macbook-pro.local/progressive/test3-4.json",
        @"http://richards-macbook-pro.local/progressive/test4-5.json",
        @"http://richards-macbook-pro.local/progressive/test5-7.json",
        @"http://richards-macbook-pro.local/progressive/test7-10.json",
        @"http://richards-macbook-pro.local/progressive/test10-15.json",
        @"http://richards-macbook-pro.local/progressive/test15-20.json",
        @"http://richards-macbook-pro.local/progressive/test20-30.json",
        @"http://richards-macbook-pro.local/progressive/test30-40.json",
        @"http://richards-macbook-pro.local/progressive/test40-50.json",
        @"http://richards-macbook-pro.local/progressive/test50.0-60.0.json",
        @"http://richards-macbook-pro.local/progressive/test60.0-100.0.json",
        @"http://richards-macbook-pro.local/progressive/test100.0-1000.0.json",
                       */
        @"http://richards-macbook-pro.local/test/models/rac_basic.json"
    ];
    
    urls = [[urls reverseObjectEnumerator] allObjects];
    
    _ctmParser = [[INVStreamBasedCTMParser alloc] init];
    _ctmParser.delegate = self;
    
    for (NSString *url in urls) {
        [_ctmParser process:[NSURL URLWithString:url]];
    }
}

-(void) streamBasedCTMParser:(INVStreamBasedCTMParser *)parser didCompleteChunk:(INVStreamBasedCTMParserChunk *)chunk shouldStop:(BOOL *)stop {
    SCNNode *node = [chunk toNode];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Added chunk to scene.");
        
        [self->_modelNode addChildNode:node];
    });
}

@end
