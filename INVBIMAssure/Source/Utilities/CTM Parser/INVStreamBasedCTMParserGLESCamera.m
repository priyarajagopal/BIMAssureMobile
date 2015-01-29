#import "INVStreamBasedCTMParserGLESCamera.h"

#import "INVStreamBasedCTMParserGLESMesh.h"

@import OpenGLES;

int INVStreamBasedCTMParserGLESCamera_ProjectionTransformUniformLocation;
int INVStreamBasedCTMParserGLESCamera_ModelViewTransformUniformLocation;
int INVStreamBasedCTMParserGLESCamera_NormalTransformUniformLocation;

int INVStreamBasedCTMParserGLESCamera_LightColorUniformLocation[6];
int INVStreamBasedCTMParserGLESCamera_LightPositionUniformLocation[6];

@implementation INVStreamBasedCTMParserGLESLight
@end

@interface INVStreamBasedCTMParserGLESCamera ()

@property GLuint program;

@end

@implementation INVStreamBasedCTMParserGLESCamera

- (id)init
{
    if (self = [super init]) {
        _projectionTransform = GLKMatrix4Identity;
        _modelViewTransform = GLKMatrix4Identity;

        _lights = [NSArray new];
    }

    return self;
}

- (void)loadProgramNamed:(NSString *)programName
{
    GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
    GLuint fsh = glCreateShader(GL_FRAGMENT_SHADER);

    NSString *vshSource = [[NSBundle mainBundle] pathForResource:programName ofType:@"vsh"];
    vshSource = [NSString stringWithContentsOfFile:vshSource encoding:NSUTF8StringEncoding error:nil];
    const char *vshSourceStr = [vshSource UTF8String];

    NSString *fshSource = [[NSBundle mainBundle] pathForResource:programName ofType:@"fsh"];
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

    _program = glCreateProgram();

    glAttachShader(_program, vsh);
    glAttachShader(_program, fsh);

    glLinkProgram(_program);

    glGetProgramInfoLog(_program, 1024, NULL, errorLog);
    puts(errorLog);

    glDetachShader(_program, vsh);
    glDetachShader(_program, fsh);

    glDeleteShader(vsh);
    glDeleteShader(fsh);

    INVStreamBasedCTMParser_PositionAttributeLocation = glGetAttribLocation(_program, "a_position");
    INVStreamBasedCTMParser_NormalAttributeLocation = glGetAttribLocation(_program, "a_normal");
    INVStreamBasedCTMParser_ColorAttributeLocation = glGetAttribLocation(_program, "a_color");

    INVStreamBasedCTMParserGLESCamera_ProjectionTransformUniformLocation =
        glGetUniformLocation(_program, "u_projectionTransform");
    INVStreamBasedCTMParserGLESCamera_ModelViewTransformUniformLocation =
        glGetUniformLocation(_program, "u_modelViewTransform");
    INVStreamBasedCTMParserGLESCamera_NormalTransformUniformLocation = glGetUniformLocation(_program, "u_normalTransform");

    int lightCount = sizeof(INVStreamBasedCTMParserGLESCamera_LightPositionUniformLocation) /
                     sizeof(*INVStreamBasedCTMParserGLESCamera_LightPositionUniformLocation);
    for (int i = 0; i < lightCount; i++) {
        char positionLocationStr[64];
        char colorLocationStr[64];

        snprintf(positionLocationStr, 64, "u_light%i_position", i);
        snprintf(colorLocationStr, 64, "u_light%i_color", i);

        INVStreamBasedCTMParserGLESCamera_LightPositionUniformLocation[i] = glGetUniformLocation(_program, positionLocationStr);
        INVStreamBasedCTMParserGLESCamera_LightColorUniformLocation[i] = glGetUniformLocation(_program, colorLocationStr);
    }
}

- (void)bindProgram
{
    glUseProgram(_program);

    GLKMatrix3 normalTransform = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelViewTransform), NULL);

    glUniformMatrix4fv(INVStreamBasedCTMParserGLESCamera_ProjectionTransformUniformLocation, 1, NO, _projectionTransform.m);
    glUniformMatrix4fv(INVStreamBasedCTMParserGLESCamera_ModelViewTransformUniformLocation, 1, NO, _modelViewTransform.m);
    glUniformMatrix3fv(INVStreamBasedCTMParserGLESCamera_NormalTransformUniformLocation, 1, NO, normalTransform.m);

    for (NSUInteger lightIndex = 0; lightIndex < 6; lightIndex++) {
        INVStreamBasedCTMParserGLESLight *light = lightIndex < self.lights.count ? self.lights[lightIndex] : nil;

        GLKVector4 lightPosition = light ? GLKVector4MakeWithVector3(light.position, 1) : GLKVector4Make(0, 0, 0, 0);
        GLKVector4 lightColor = light ? light.color : GLKVector4Make(0, 0, 0, 0);

        lightPosition = GLKMatrix4MultiplyVector4(_modelViewTransform, lightPosition);

        glUniform4fv(INVStreamBasedCTMParserGLESCamera_LightColorUniformLocation[lightIndex], 1, lightColor.v);
        glUniform4fv(INVStreamBasedCTMParserGLESCamera_LightPositionUniformLocation[lightIndex], 1, lightPosition.v);
    }
}

@end
