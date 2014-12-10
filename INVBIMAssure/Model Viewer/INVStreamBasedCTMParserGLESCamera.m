#import "INVStreamBasedCTMParserGLESCamera.h"

@import OpenGLES;

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
    GLuint projectionTransformLocation = glGetUniformLocation(program, "u_projectionTransform");
    GLuint modelViewTransformLocation = glGetUniformLocation(program, "u_modelViewTransform");
    GLuint normalTransformLocation = glGetUniformLocation(program, "u_normalTransform");

    GLKMatrix3 normalTransform = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewTransform), NULL);
    
    glProgramUniformMatrix4fvEXT(program, projectionTransformLocation, 1, NO, _projectionTransform.m);
    glProgramUniformMatrix4fvEXT(program, modelViewTransformLocation,  1, NO,  _modelViewTransform.m);
    glProgramUniformMatrix3fvEXT(program, normalTransformLocation,     1, NO,      normalTransform.m);
    
    for (NSUInteger lightIndex = 0; lightIndex < self.lights.count && lightIndex < 6; lightIndex++) {
        char lightColorUniformStr[64];
        char lightPositionUniformStr[64];
        
        snprintf(lightColorUniformStr, 64, "u_light%lu_color", (unsigned long) lightIndex);
        snprintf(lightPositionUniformStr, 64, "u_light%lu_position", (unsigned long) lightIndex);
        
        GLuint lightColorLocation = glGetUniformLocation(program, lightColorUniformStr);
        GLuint lightPositionLocation = glGetUniformLocation(program, lightPositionUniformStr);
        
        INVStreamBasedCTMParserGLESLight *light = self.lights[lightIndex];
        
        GLKVector3 lightPosition = light.position;
        // lightPosition = GLKMatrix4MultiplyVector3WithTranslation(_modelViewTransform, lightPosition);
        
        glProgramUniform4fvEXT(program, lightColorLocation, 1, light.color.v);
        glProgramUniform4fvEXT(program, lightPositionLocation, 1, lightPosition.v);
    }
}

@end
