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
    
    GLKBBox _overallBBox;
    
    GLKVector3 cameraPosition;
    GLKVector3 lookAt;
}

@end

@implementation INVModelViewerViewController

-(void) setupScene {
    // create and add a camera to the scene
    _meshes = [NSMutableArray new];
    
    _camera = [INVStreamBasedCTMParserGLESCamera new];
    [_camera loadProgramNamed:@"ModelViewer"];
    
    [self _resetCamera];
    
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

-(void) prepareGL {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _context.multiThreaded = YES;
    
    [EAGLContext setCurrentContext:_context];
    
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    [self setupScene];
    
    _ctmParser = [[INVStreamBasedCTMParser alloc] init];
    _ctmParser.delegate = self;
    
    // NSURLRequest *request = [INVGlobalDataManager.sharedInstance.invServerClient requestToFetchModelViewForId:self.modelId];
    NSURL *url = [NSURL URLWithString:@"http://richards-macbook-pro.local/progressive/office/office_mg2.json"];
    
    [_ctmParser process:url];
}

-(void) viewDidLoad {
}

-(void) viewDidAppear:(BOOL)animated {
    [self prepareGL];
}

-(void) update {
    float aspect = (self.view.bounds.size.width / self.view.bounds.size.height);
    
    _camera.projectionTransform = GLKMatrix4MakePerspective(55, aspect, 1, 10000);
    
    GLKVector3 mid = GLKBBoxCenter(_overallBBox);
    
    /*
    _camera.projectionTransform = GLKMatrix4Translate(_camera.projectionTransform, -mid.x, -mid.y, -mid.z - 150);
    _camera.projectionTransform = GLKMatrix4Rotate(_camera.projectionTransform, M_PI / 2, 1, 0, 0);
    */

    _camera.projectionTransform = GLKMatrix4Multiply(
        GLKMatrix4MakePerspective(55, aspect, 1, 10000),
        GLKMatrix4MakeLookAt(
            cameraPosition.x, cameraPosition.y, cameraPosition.z,
            lookAt.x, lookAt.y, lookAt.z,
            0, 0, -1
        )
    );
}

-(void) _resetCamera {
    GLKVector3 mid = GLKBBoxCenter(_overallBBox);
    GLKVector3 size = GLKBBoxSize(_overallBBox);
    float distance = GLKVector3Length(size) * 1.2f;
    
    cameraPosition = GLKVector3Make(100, -100, 10);
    lookAt = GLKVector3Make(0, 0, 0);
    
    GLKVector3 direction = GLKVector3Normalize(GLKVector3Subtract(cameraPosition, lookAt));
    cameraPosition = GLKVector3Make(
        mid.x + direction.x * distance,
        mid.y + direction.y * distance,
        mid.z + direction.z * distance
    );
    
    lookAt = mid;
    
    _camera.modelViewTransform = GLKMatrix4Identity;
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
        self->_overallBBox = GLKBBoxUnion(self->_overallBBox, mesh.boundingBox);
        
        [self _resetCamera];
        [self->_meshes addObject:mesh];
    });
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    touches = [event allTouches];
    
    if (touches.count == 1) {
        UITouch *touch = [touches anyObject];
        
        CGPoint lastPoint = [touch previousLocationInView:self.view];
        CGPoint newPoint = [touch locationInView:self.view];
    
        float changedX = newPoint.x - lastPoint.y;
        float changedY = newPoint.y - lastPoint.y;
        
        _camera.modelViewTransform = GLKMatrix4Rotate(_camera.modelViewTransform, 0.05, changedX, changedY, 0);
    }
    if (touches.count == 2) {
        UITouch *touch1 = [touches allObjects][0];
        UITouch *touch2 = [touches allObjects][1];
        
        CGPoint touch1Point = [touch1 locationInView:self.view];
        CGPoint touch2Point = [touch2 locationInView:self.view];
        
        CGPoint touch1LastPoint = [touch1 previousLocationInView:self.view];
        CGPoint touch2LastPoint = [touch2 previousLocationInView:self.view];
        
        float distance = GLKVector2Distance(
            GLKVector2Make(touch1Point.x, touch1Point.y),
            GLKVector2Make(touch2Point.x, touch2Point.y)
        );
        
        float lastDistance = GLKVector2Distance(
            GLKVector2Make(touch1LastPoint.x, touch1LastPoint.y),
            GLKVector2Make(touch2LastPoint.x, touch2LastPoint.y)
        );
        
        float sign = distance > lastDistance ? 1 : -1;
        float scale = sign * (fabs(lastDistance -  distance)) * 0.5;
        
        GLKVector3 change = GLKVector3Make(0, scale, 0);

        cameraPosition = GLKVector3Add(cameraPosition, change);
    }
    
    if (touches.count == 3) {
        UITouch *touch = [touches anyObject];
        
        CGPoint lastPoint = [touch previousLocationInView:self.view];
        CGPoint newPoint = [touch locationInView:self.view];
        
        float changedX = newPoint.x - lastPoint.x;
        float changedY = newPoint.y - lastPoint.y;
        
        GLKVector3 change = GLKVector3Make(-changedX / 4, 0, changedY / 4);
        
        cameraPosition = GLKVector3Add(cameraPosition, change);
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (touch.tapCount == 3) {
        [self _resetCamera];
    }
}

@end
