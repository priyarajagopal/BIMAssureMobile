//
//  GameViewController.m
//  INVModelViewerGLES
//
//  Created by Richard Ross on 11/19/14.
//  Copyright (c) 2014 Invicara. All rights reserved.
//

#import "INVModelViewerViewController.h"

#import "INVStreamBasedCTMParser.h"
#import "INVStreamBasedCTMParserGLESCamera.h"
#import "INVStreamBasedCTMParserGLESMesh.h"

@import OpenCTM;
@import GLKit;

void classDump(Class);

@interface INVModelViewerViewController ()<INVStreamBasedCTMParserDelegate> {
    EAGLContext *_context;
    
    INVStreamBasedCTMParser *_ctmParser;
    INVStreamBasedCTMParserGLESCamera *_camera;
    
    NSMutableArray *_meshes;
}

@end

@implementation INVModelViewerViewController

-(void) setupScene {
    // create and add a camera to the scene
    _meshes = [NSMutableArray new];
    
    _camera = [INVStreamBasedCTMParserGLESCamera new];
    [_camera loadProgramNamed:@"ModelViewer"];
    
    // _camera.projectionTransform = GLKMatrix4Translate(_camera.projectionTransform, 0, 15, 250);
    // _camera.modelViewTransform = GLKMatrix4MakeRotation(M_PI / 2, 1, 0, 0);

    GLKVector3 lightPostions[6] = {
        {  1000,     0,     0 },
        {     0,  1000,     0 },
        {     0,     0,  1000 },
        { -1000,     0,     0 },
        {     0, -1000,     0 },
        {     0,     0, -1000 }
    };
    
    NSMutableArray *lights = [NSMutableArray new];
    for (int i = 0; i < 6; i++) {
        // create and add a light to the scene
        INVStreamBasedCTMParserGLESLight *light = [INVStreamBasedCTMParserGLESLight new];
        light.color = GLKVector4Make(0.66, 0.66, 0.66, 1);
        light.position = lightPostions[i];
        
        [lights addObject:light];
    }
    
    _camera.lights = lights;
}

-(void) viewDidLoad {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    
    glEnable(GL_DEPTH_TEST);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glBlendEquation(GL_FUNC_ADD);
    
    [self setupScene];
    
    NSArray *urls = @[
        @"http://richards-macbook-pro.local/test/models/SampleHouse.json"
    ];
    
    urls = [[urls reverseObjectEnumerator] allObjects];
    
    _ctmParser = [[INVStreamBasedCTMParser alloc] init];
    _ctmParser.delegate = self;
    
    for (NSString *url in urls) {
        [_ctmParser process:[NSURL URLWithString:url]];
    }
}

-(void) update {
    float aspect = (self.view.bounds.size.width / self.view.bounds.size.height);
    
    _camera.projectionTransform = GLKMatrix4MakePerspective(55, aspect, 0.5, 10000);
    _camera.projectionTransform = GLKMatrix4Translate(_camera.projectionTransform, 0, 15, -100);
    
    // _camera.modelViewTransform = GLKMatrix4Rotate(_camera.modelViewTransform, self.timeSinceLastUpdate, 1, 1, 0);
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [_camera bindProgram];
    
    for (INVStreamBasedCTMParserGLESMesh *mesh in _meshes) {
        [mesh draw];
    }
}

-(void) streamBasedCTMParser:(INVStreamBasedCTMParser *)parser
             didCompleteMesh:(INVStreamBasedCTMParserGLESMesh *)mesh
                  shouldStop:(BOOL *)stop {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_meshes addObject:mesh];
    });
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([event.allTouches count] == 1) {
        
    }
}

@end
