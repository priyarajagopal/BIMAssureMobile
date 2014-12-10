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
    
    GLuint _program;
    
    INVStreamBasedCTMParser *_ctmParser;
    INVStreamBasedCTMParserGLESCamera *_camera;
    
    NSMutableArray *_meshes;
}

@end

@implementation INVModelViewerViewController

-(GLuint) createProgram {
    static GLuint program;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
        GLuint fsh = glCreateShader(GL_FRAGMENT_SHADER);
        
        NSString *vshSource = [[NSBundle mainBundle] pathForResource:@"ModelViewer" ofType:@"vsh"];
        vshSource = [NSString stringWithContentsOfFile:vshSource encoding:NSUTF8StringEncoding error:nil];
        const char *vshSourceStr = [vshSource UTF8String];
        
        NSString *fshSource = [[NSBundle mainBundle] pathForResource:@"ModelViewer" ofType:@"fsh"];
        fshSource = [NSString stringWithContentsOfFile:fshSource encoding:NSUTF8StringEncoding error:nil];
        const char *fshSourceStr = [fshSource UTF8String];
        
        glShaderSource(vsh, 1, &vshSourceStr, NULL);
        glShaderSource(fsh, 1, &fshSourceStr, NULL);
        
        glCompileShader(vsh);
        glCompileShader(fsh);
        
        char errorLog[1024];
        glGetShaderInfoLog(vsh, 1024, NULL, errorLog);
        puts(errorLog);
        
        glGetShaderInfoLog(fsh, 1024, NULL, errorLog);
        puts(errorLog);
        
        program = glCreateProgram();
        
        glAttachShader(program, vsh);
        glAttachShader(program, fsh);
        
        glLinkProgram(program);
        
        glGetProgramInfoLog(program, 1024, NULL, errorLog);
        puts(errorLog);
        
        glDetachShader(program, vsh);
        glDetachShader(program, fsh);
        
        glDeleteShader(vsh);
        glDeleteShader(fsh);
    });
    
    return program;
}

-(void) setupScene {
    // create and add a camera to the scene
    _program = [self createProgram];
    _meshes = [NSMutableArray new];
    
    _camera = [INVStreamBasedCTMParserGLESCamera new];
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
    
    [self setupScene];
}

-(void) update {
    _camera.modelViewTransform = GLKMatrix4Rotate(_camera.modelViewTransform, self.timeSinceLastUpdate, 1, 1, 0);
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.5, 0.5, 0.5, 0.5);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    float aspect = (self.view.bounds.size.width / self.view.bounds.size.height);
    _camera.projectionTransform = GLKMatrix4MakePerspective(55, aspect, 0.5, 10000);
    _camera.projectionTransform = GLKMatrix4Translate(_camera.projectionTransform, 0, 15, -100);
        
    glUseProgram(_program);
    
    [_camera bindTo:_program];
    
    for (INVStreamBasedCTMParserGLESMesh *mesh in _meshes) {
        [mesh drawUsing:_program];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

-(void) streamBasedCTMParser:(INVStreamBasedCTMParser *)parser didCompleteChunk:(INVStreamBasedCTMParserChunk *)chunk shouldStop:(BOOL *)stop {
    INVStreamBasedCTMParserGLESMesh *mesh = [[INVStreamBasedCTMParserGLESMesh alloc] initWithChunk:chunk];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Added chunk to scene.");
        
        [self->_meshes addObject:mesh];
    });
}

@end
