#import "INVStreamBasedCTMParserGLESCamera.h"

@import OpenGLES;

int INVStreamBasedCTMParserGLESCamera_ProjectionTransformUniformLocation;
int INVStreamBasedCTMParserGLESCamera_ModelViewTransformUniformLocation;
int INVStreamBasedCTMParserGLESCamera_NormalTransformUniformLocation;

int INVStreamBasedCTMParserGLESCamera_LightColorUniformLocation[6];
int INVStreamBasedCTMParserGLESCamera_LightPositionUniformLocation[6];

@implementation INVStreamBasedCTMParserGLESLight
@end

@implementation INVStreamBasedCTMParserGLESCamera

-(id) init {
    if (self = [super init]) {
        _projectionTransform = GLKMatrix4Identity;
        _modelViewTransform = GLKMatrix4Identity;
        
        _lights = [NSArray new];
    }
    
    return self;
}

-(void) bindTo:(unsigned int)program {
    GLKMatrix3 normalTransform = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewTransform), NULL);
    
    glProgramUniformMatrix4fvEXT(program, INVStreamBasedCTMParserGLESCamera_ProjectionTransformUniformLocation, 1, NO, _projectionTransform.m);
    glProgramUniformMatrix4fvEXT(program, INVStreamBasedCTMParserGLESCamera_ModelViewTransformUniformLocation,  1, NO,  _modelViewTransform.m);
    glProgramUniformMatrix3fvEXT(program, INVStreamBasedCTMParserGLESCamera_NormalTransformUniformLocation,     1, NO,      normalTransform.m);
    
    for (NSUInteger lightIndex = 0; lightIndex < 6; lightIndex++) {
        INVStreamBasedCTMParserGLESLight *light = lightIndex < self.lights.count ? self.lights[lightIndex] : nil;
        
        GLKVector3 lightPosition = light ? light.position : GLKVector3Make(0, 0, 0);
        GLKVector4 lightColor = light ? light.color : GLKVector4Make(0, 0, 0, 0);
        
        lightPosition = GLKMatrix4MultiplyVector3WithTranslation(_modelViewTransform, lightPosition);
        
        glProgramUniform4fvEXT(program, INVStreamBasedCTMParserGLESCamera_LightColorUniformLocation[lightIndex], 1, lightColor.v);
        glProgramUniform4fvEXT(program, INVStreamBasedCTMParserGLESCamera_LightPositionUniformLocation[lightIndex], 1, lightPosition.v);
    }
}

@end
