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
    NSMutableArray *_transparentMeshes;
    
    GLKBBox _overallBBox;
    
    GLKVector3 cameraPosition;
    GLKVector3 cameraDirection;
    
    GLKMatrix4 rotationMatrix;
    
    NSUInteger _vertexCount;
    NSUInteger _triangleCount;
    
    BOOL _transparentEnabled;
}

@end

@implementation INVModelViewerViewController

-(void) setupScene {
    // create and add a camera to the scene
    _overallBBox = GLKBBoxEmpty;
    _meshes = [NSMutableArray new];
    _transparentMeshes = [NSMutableArray new];
    _transparentEnabled = YES;
    
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
}

-(void) viewWillAppear:(BOOL)animated {
    [self setHidesBottomBarWhenPushed:YES];
    [self prepareGL];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        [self loadModel];
    });
    
    [super viewWillAppear:animated];
}

-(void) loadModel {
    _ctmParser = [[INVStreamBasedCTMParser alloc] init];
    _ctmParser.delegate = self;
    
    [_ctmParser process:[[INVGlobalDataManager sharedInstance].invServerClient requestToFetchModelViewForId:self.fileVersionId]];
}

-(void) update {
    float aspect = (self.view.bounds.size.width / self.view.bounds.size.height);
    
    _camera.projectionTransform = GLKMatrix4MakePerspective(55, aspect, 1, 10000);
    
    GLKVector3 mid = GLKBBoxCenter(_overallBBox);
    
    /*
    _camera.projectionTransform = GLKMatrix4Translate(_camera.projectionTransform, -mid.x, -mid.y, -mid.z - 150);
    _camera.projectionTransform = GLKMatrix4Rotate(_camera.projectionTransform, M_PI / 2, 1, 0, 0);
    */
    
    GLKVector3 projectedPosition = GLKVector3Make(cameraPosition.x, cameraPosition.y, cameraPosition.z);
    projectedPosition = GLKVector3Add(projectedPosition, cameraDirection);

    _camera.projectionTransform = GLKMatrix4Multiply(
        GLKMatrix4MakePerspective(55, aspect, 1, 10000),
        GLKMatrix4MakeLookAt(
            cameraPosition.x, cameraPosition.y, cameraPosition.z,
            projectedPosition.x, projectedPosition.y, projectedPosition.z,
            0, 0, -1
        )
    );
    
    _camera.modelViewTransform = rotationMatrix;
}

-(void) _resetCamera {
    GLKVector3 mid = GLKBBoxCenter(_overallBBox);
    // GLKVector3 size = GLKBBoxSize(_overallBBox);
    // float distance = GLKVector3Length(size) * 0.5f;
    
    cameraPosition = GLKVector3Make(mid.x, mid.y - 250, mid.z);
    GLKVector3 lookAt = cameraPosition;
    lookAt.y += 1;
    
    cameraDirection = GLKVector3Subtract(lookAt, cameraPosition);
    rotationMatrix = GLKMatrix4Identity;
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [_camera bindProgram];
    
    for (INVStreamBasedCTMParserGLESMesh *mesh in _meshes) {
        [mesh draw];
    }
    
    if (_transparentEnabled) {
        glDepthMask(GL_FALSE);
    
        for (INVStreamBasedCTMParserGLESMesh *mesh in _transparentMeshes) {
            [mesh draw];
        }
    
        glDepthMask(GL_TRUE);
    }
}

-(void) streamBasedCTMParser:(INVStreamBasedCTMParser *)parser
             didCompleteMesh:(INVStreamBasedCTMParserGLESMesh *)mesh
                  shouldStop:(BOOL *)stop {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_overallBBox = GLKBBoxUnion(self->_overallBBox, mesh.boundingBox);
        self->_overallBBox.min.z = fmaxf(self->_overallBBox.min.z, 0);
        
        self->_vertexCount += [mesh vertexCount];
        self->_triangleCount += [mesh triangleCount];
        
        NSLog(@"Currently: %10lu verts, %10lu tris.", (unsigned long)self->_vertexCount, (unsigned long)self->_triangleCount);
        
        if ([self->_meshes count] == 0) {
            [self _resetCamera];
        }
        
        if (mesh.transparent) {
            [self->_transparentMeshes addObject:mesh];
        } else {
            [self->_meshes addObject:mesh];
        }
    });
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    touches = [event allTouches];
    
    if (touches.count == 1) {
        UITouch *touch = [touches anyObject];
        
        CGPoint lastPoint = [touch previousLocationInView:self.view];
        CGPoint newPoint = [touch locationInView:self.view];
    
        float changedX = (newPoint.x - lastPoint.x) / 1000;
        float changedY = (newPoint.y - lastPoint.y) / 1000;
        
        GLKVector3 camera = GLKVector3Make(cameraPosition.x, cameraPosition.y, cameraPosition.z);
        camera = GLKMatrix4MultiplyAndProjectVector3(GLKMatrix4Invert(_camera.projectionTransform, NULL), camera);
        
        rotationMatrix = GLKMatrix4Multiply(
            GLKMatrix4Translate(
                GLKMatrix4Rotate(
                    GLKMatrix4MakeTranslation(-camera.x, camera.y, -camera.z),
                    0.05, -changedY, 0, -changedX
                ),
                camera.x, -camera.y, camera.z
            ),
            rotationMatrix
        );
         
        // cameraDirection.x += cosf(changedX);
        // cameraDirection.y += tanf(changedX);
        
        // cameraDirection.x += changedX / 1000;
        // cameraDirection.y += changedY / 1000;
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
        float scale = sign * (fabs(lastDistance -  distance)) * 0.25;
        
        GLKVector3 change = GLKVector3Make(0, scale, 0);
        // change = GLKVector3Multiply(change, cameraDirection);

        cameraPosition = GLKVector3Add(cameraPosition, change);
    }
    
    if (touches.count == 3) {
        UITouch *touch = [touches anyObject];
        
        CGPoint lastPoint = [touch previousLocationInView:self.view];
        CGPoint newPoint = [touch locationInView:self.view];
        
        float changedX = newPoint.x - lastPoint.x;
        float changedY = newPoint.y - lastPoint.y;
        
        GLKVector3 change = GLKVector3Make(-changedX / 4, 0, changedY / 4);
        //change = GLKVector3Multiply(change, cameraDirection);
        
        cameraPosition = GLKVector3Add(cameraPosition, change);
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (touch.tapCount == 3) {
        [self _resetCamera];
    }
    
    if (touch.tapCount == 2) {
        /*
        // Do a raycast
        CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
        
        float xNormalized = ((2 * touchPoint.x) / self.view.bounds.size.width) - 1;
        float yNormalized = ((2 * touchPoint.y) / self.view.bounds.size.height) - 1;
        
        GLKVector3 normalizedDeviceCoords = GLKVector3Make(xNormalized, yNormalized, 1);
        GLKVector4 rayClipCoordinates = GLKVector4Make(normalizedDeviceCoords.x, normalizedDeviceCoords.y, -1, 1);
        
        GLKVector4 rayEyeCoordinates = GLKMatrix4MultiplyVector4(GLKMatrix4Invert(_camera.projectionTransform, NULL), rayClipCoordinates);
        rayEyeCoordinates.z = 1;
        rayEyeCoordinates.w = 0;
        
        GLKVector4 rayWorldCoordinates = GLKMatrix4MultiplyVector4(GLKMatrix4Invert(_camera.modelViewTransform, NULL), rayEyeCoordinates);
        GLKVector3 rayDirection = GLKVector3Normalize(GLKVector3Make(rayWorldCoordinates.x, rayWorldCoordinates.y, rayWorldCoordinates.z));
        
        GLKVector3 camera = cameraPosition;
        
        camera = GLKMatrix4MultiplyAndProjectVector3(GLKMatrix4Invert(_camera.projectionTransform, NULL), camera);
        camera = GLKMatrix4MultiplyVector3WithTranslation(GLKMatrix4Invert(_camera.modelViewTransform, NULL), camera);
        
        // Now do a ray-cast.
        for (INVStreamBasedCTMParserGLESMesh *mesh in [_meshes arrayByAddingObjectsFromArray:_transparentMeshes]) {
            NSString *elementId = [mesh elementIdOfElementInterceptingRay:camera direction:rayDirection];
            
            if (elementId) {
                [mesh setColorOfElementWithId:elementId withColor:GLKVector4Make(1, 0, 1, 1)];
                NSLog(@"%@", elementId);
            }
        }
         */
    }
}

-(IBAction) toggleSidebar:(id)sender {
}

-(IBAction) goHome:(id)sender {
    [self _resetCamera];
}


-(IBAction) toggleShadow:(id)sender {
}

-(IBAction) toggleGlass:(id)sender {
    _transparentEnabled = !_transparentEnabled;
}

-(IBAction) toggleVisible:(id)sender {
}

@end
