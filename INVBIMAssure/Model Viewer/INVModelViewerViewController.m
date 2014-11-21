//
//  GameViewController.m
//  INVModelViewerGLES
//
//  Created by Richard Ross on 11/19/14.
//  Copyright (c) 2014 Invicara. All rights reserved.
//

#import "INVModelViewerViewController.h"

#import "INVCTMModel.h"
#import "INVJSONCTMManager.h"

@import OpenCTM;

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

GLfloat gCubeVertexData[2048];
GLushort gCubeIndices[2024];
GLint triangleCount;

@interface INVModelViewerViewController () {
    GLKMatrix4 _projectionMatrix;
    GLKMatrix4 _modelViewMatrix;
    
    INVJSONCTMManager *_manager;
    NSArray *_models;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation INVModelViewerViewController


struct _readDataStruct {
    const void *ptr;
    size_t remain;
};

CTMuint _ctmReadData(void *aBuf, CTMuint aCount, void *aUserData) {
    struct _readDataStruct *readDataStruct = (struct _readDataStruct *) aUserData;
    
    unsigned long read = MIN(aCount, readDataStruct->remain);
    memcpy(aBuf, readDataStruct->ptr, read);
    
    readDataStruct->ptr += read;
    readDataStruct->remain -= read;
    
    return (unsigned) read;
}

-(void) loadCTM {
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"SampleHouse" ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
        
        _manager = [[INVJSONCTMManager alloc] initWithJSON:jsonData];
        _models = [_manager allModels];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self loadCTM];
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    self.effect.light0.enabled = GL_TRUE;
    self.effect.colorMaterialEnabled = GL_TRUE;
    
    self.effect.light0.position = GLKVector4Make(0, 0, -10, 0);
    
    self.effect.lightModelTwoSided = YES;
    
    self.effect.material.emissiveColor = GLKVector4Make(0.5, 0.5, 0.5, 0.5);
    self.effect.material.diffuseColor = GLKVector4Make(0.5, 0.5, 0.5, 1);
    
    self.effect.light0.specularColor = GLKVector4Make(0.9f, 0.9f, 0.9f, 0.5);
    self.effect.light0.diffuseColor = GLKVector4Make(0.4f, 0.4f, 0.4f, 0.5);
    self.effect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 0.5);
     
    GLKView *glkView = (GLKView *) self.view;
    glkView.drawableMultisample = GLKViewDrawableMultisample4X;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    // glEnable(GL_DEPTH_TEST);
    [self resetCamera];
    
    for (INVCTMModel *model in _models) {
        [model prepare];
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

    self.effect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    self.effect.transform.projectionMatrix = _projectionMatrix;
    self.effect.transform.modelviewMatrix = _modelViewMatrix;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    for (INVCTMModel *model in _models) {
        [model draw];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    touches = [event allTouches];
    
    if (touches.count == 1) {
        UITouch *touch = [touches anyObject];
        
        CGPoint lastPoint = [touch previousLocationInView:self.view];
        CGPoint newPoint = [touch locationInView:self.view];
    
        float changedX = newPoint.x - lastPoint.x;
        float changedY = newPoint.y - lastPoint.y;
        
        _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, changedY / 100, 1, 0, 0);
        _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, changedX / 100, 0, 1, 0);
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
        float scale = 1 + (sign * distance / 10000);

        _modelViewMatrix = GLKMatrix4Scale(_modelViewMatrix, scale, scale, scale);
    }
    if (touches.count == 3) {
        UITouch *touch = [touches anyObject];
        
        CGPoint lastPoint = [touch previousLocationInView:self.view];
        CGPoint newPoint = [touch locationInView:self.view];
        
        float changedX = newPoint.x - lastPoint.x;
        float changedY = newPoint.y - lastPoint.y;
        
        _modelViewMatrix = GLKMatrix4Multiply(
            GLKMatrix4MakeTranslation(changedX / 10, -changedY / 10, 0),
            _modelViewMatrix
        );
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (touch.tapCount == 3) {
        [self resetCamera];
        return;
    }
    if (touch.tapCount == 4) {
        [self toggleWireframe];
        return;
    }
}

-(void) resetCamera {
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(75), aspect, 0.0001, 10000.0f);
    
    _modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -100.0f);    _modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -100.0f);
}

-(void) toggleWireframe {
    for (INVCTMModel *model in _models) {
        model.wireframe = !model.wireframe;
    }
}

@end
