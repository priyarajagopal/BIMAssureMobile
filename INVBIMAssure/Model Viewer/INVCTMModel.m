#import "INVCTMModel.h"

static const char *INV_FRAG_SHADER_SOURCE =
"\n\
varying lowp vec4 colorVarying;\n\
\n\
void main() {\n\
    gl_FragColor = colorVarying;\n\
}\n\
";
static const char *INV_VERT_SHADER_SOURCE = \
"\n\
attribute vec4 positionAttrib;\n\
attribute vec3 normalAttrib;\n\
attribute vec4 colorAttrib;\n\
\n\
varying lowp vec4 colorVarying;\n\
\n\
uniform mat4 cameraMatrix;\n\
uniform mat4 modelMatrix;\n\
\n\
void main() {\n\
    colorVarying = colorAttrib;\n\
\n\
    gl_Position = positionAttrib;\n\
}\n\
";

static int cameraMatrixUniformLocation;
static int modelMatrixUniformLocation;

static GLuint shaderProgram() {
    static GLuint program;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    });
    
    
    return program;
}

@import OpenCTM;

@implementation INVCTMModel {
    int _triangleCount;
    int _vertexCount;
    
    size_t _vertexSize;
    float *_vertexData;
    
    size_t _indicesSize;
    GLushort *_indices;
    
    GLenum _mode;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLuint _vertShader;
    GLuint _fragShader;
    GLuint _shaderProgram;
    
    GLKVector4 _color;
    GLKMatrix4 _transform;
    
    BOOL _isPrepared;
    BOOL _isProgramPrepared;
}

struct ctmReadNSDataUserData {
    __unsafe_unretained NSData *buffer;
    off_t offset;
};

CTMuint ctmReadNSData(void *buf, CTMuint size, void *userData) {
    struct ctmReadNSDataUserData *ctmReadNSDataUserData = (struct ctmReadNSDataUserData *) userData;
    
    CTMuint read = (CTMuint) MIN(size, [ctmReadNSDataUserData->buffer length] - ctmReadNSDataUserData->offset);
    
    memcpy(buf, [ctmReadNSDataUserData->buffer bytes] + ctmReadNSDataUserData->offset, read);
    ctmReadNSDataUserData->offset += read;
    
    return read;
}

-(id) initWithCTMData:(NSData *)data mode:(GLenum) drawMode color:(UIColor *)color {
    if (self = [super init]) {
        _mode = drawMode;
        _transform = GLKMatrix4Identity;
        if (color == nil) {
            color = [UIColor whiteColor];
        }
        
        CGFloat r, g, b, a;
        [color getRed:&r green:&g blue:&b alpha:&a];
        
        _color.r = r;
        _color.g = g;
        _color.b = b;
        _color.a = a;
        
        CTMcontext context = ctmNewContext(CTM_IMPORT);
        
        struct ctmReadNSDataUserData userInfo = { data };
        ctmLoadCustom(context, ctmReadNSData, &userInfo);
        
        [self loadWithCTMContext:context];
        
        ctmFreeContext(context);
    }
    
    return self;
}

-(id) copyWithZone:(NSZone *)zone {
    INVCTMModel *newModel = [[INVCTMModel allocWithZone:zone] init];
    newModel->_triangleCount = self->_triangleCount;
    
    newModel->_vertexCount = self->_vertexCount;
    newModel->_vertexSize = self->_vertexSize;
    newModel->_vertexData = malloc(self->_vertexSize);
    memcpy(newModel->_vertexData, self->_vertexData, self->_vertexSize);
    
    newModel->_indicesSize = self->_indicesSize;
    newModel->_indices = malloc(self->_indicesSize);
    memcpy(newModel->_indices, self->_indices, self->_indicesSize);
    
    newModel->_mode = self->_mode;
    
    // Don't copy the vertex array or buffer. Those need to be separate per-model.
    newModel->_color = self->_color;
    newModel->_transform = self->_transform;
    
    return newModel;
}

-(void) neighboringTris:(int) vertIndex
                inArray:(int *) tris
                  count:(unsigned *) count {
    *count = 0;
    
    GLKVector3 vertVector = GLKVector3MakeWithArray(&_vertexData[(vertIndex * 10)]);
    
    for (unsigned triIndex = 0; triIndex < _triangleCount; triIndex++) {
        int triVertIndex = _indices[triIndex];
    
        GLKVector3 triP1 = GLKVector3MakeWithArray(&_vertexData[((triVertIndex + 0) * 10)]);
        GLKVector3 triP2 = GLKVector3MakeWithArray(&_vertexData[((triVertIndex + 1) * 10)]);
        GLKVector3 triP3 = GLKVector3MakeWithArray(&_vertexData[((triVertIndex + 2) * 10)]);
        
        if (GLKVector3AllEqualToVector3(vertVector, triP1) ||
            GLKVector3AllEqualToVector3(vertVector, triP2) ||
            GLKVector3AllEqualToVector3(vertVector, triP3)) {
            tris[*count] = triIndex;
            
            (*count)++;
        }
    }
    
    printf("%i\n", *count);
}

-(GLKVector3) surfaceNormalFor:(int) triIndex {
    int triVertIndex = _indices[triIndex];
    
    GLKVector3 triP1 = GLKVector3MakeWithArray(&_vertexData[((triVertIndex + 0) * 10)]);
    GLKVector3 triP2 = GLKVector3MakeWithArray(&_vertexData[((triVertIndex + 1) * 10)]);
    GLKVector3 triP3 = GLKVector3MakeWithArray(&_vertexData[((triVertIndex + 2) * 10)]);
    
    GLKVector3 U = GLKVector3Subtract(triP2, triP1);
    GLKVector3 V = GLKVector3Subtract(triP3, triP1);
    
    GLKVector3 normal = GLKVector3Make(0, 0, 0);
    
    normal.x = (U.y * V.z) - (U.z * V.y);
    normal.y = (U.z * V.x) - (U.x * V.z);
    normal.z = (U.x * V.y) - (U.y * V.x);
    
    return normal;
}

-(void) loadWithCTMContext:(CTMcontext) context {
    _transform = GLKMatrix4Identity;
    
    _triangleCount = ctmGetInteger(context, CTM_TRIANGLE_COUNT);
    _vertexCount = ctmGetInteger(context, CTM_VERTEX_COUNT);
    
    const float *verts = ctmGetFloatArray(context, CTM_VERTICES);
    const unsigned *indices = ctmGetIntegerArray(context, CTM_INDICES);
    
    _vertexSize = sizeof(float) * (3 + 3 + 4) * _vertexCount;
    _indicesSize = sizeof(GLushort) * _triangleCount;
    
    _vertexData = malloc(_vertexSize);
    _indices = malloc(_indicesSize);
    
    for (unsigned vertIndex = 0, vertDataIndex = 0; vertIndex < _vertexCount * 3; vertIndex += 3, vertDataIndex += 10) {
        // Vertex
        _vertexData[vertDataIndex + 0] = verts[vertIndex];
        _vertexData[vertDataIndex + 1] = verts[vertIndex + 1];
        _vertexData[vertDataIndex + 2] = verts[vertIndex + 2];
        
        _vertexData[vertDataIndex + 3] = 0;
        _vertexData[vertDataIndex + 4] = 0;
        _vertexData[vertDataIndex + 5] = -1;
        
        // Color
        _vertexData[vertDataIndex + 6] = _color.r;
        _vertexData[vertDataIndex + 7] = _color.g;
        _vertexData[vertDataIndex + 8] = _color.b;
        _vertexData[vertDataIndex + 9] = 1;
    }
    
    for (unsigned index = 0; index < _triangleCount; index++) {
        _indices[index] = indices[index];
    }
}

-(void) prepare {
    if (_isPrepared) return;
    
    // first transform the triangles using _transform
    for (unsigned vertDataIndex = 0; vertDataIndex < _vertexCount * 10; vertDataIndex += 10) {
        GLKVector4 vector = GLKVector4Make(
            _vertexData[vertDataIndex + 0],
            _vertexData[vertDataIndex + 1],
            _vertexData[vertDataIndex + 2],
            1
        );
        
        vector = GLKMatrix4MultiplyVector4(_transform, vector);
        
        _vertexData[vertDataIndex + 0] = vector.x;
        _vertexData[vertDataIndex + 1] = vector.y;
        _vertexData[vertDataIndex + 2] = vector.z;
    }
    
    _transform = GLKMatrix4Identity;
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, _vertexSize, _vertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, (int) (_vertexSize / _vertexCount), 0);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, (int) (_vertexSize / _vertexCount), (void *) (sizeof(float) * 3));
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, (int) (_vertexSize / _vertexCount), (void *) (sizeof(float) * 6));
    
    glBindVertexArrayOES(0);
    
    _isPrepared = YES;
}

+(GLuint) prepareProgram {
    // Note: not currently used
    static GLuint shaderProgram;
    static GLuint vertShader;
    static GLuint fragShader;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GLchar buffer[512];
        
        vertShader = glCreateShader(GL_VERTEX_SHADER);
        fragShader = glCreateShader(GL_FRAGMENT_SHADER);
        
        glShaderSource(vertShader, 1, &INV_VERT_SHADER_SOURCE, NULL);
        glShaderSource(fragShader, 1, &INV_FRAG_SHADER_SOURCE, NULL);
        
        glCompileShader(vertShader);
        glGetShaderInfoLog(vertShader, 512, NULL, buffer);
        puts(buffer);
        
        glCompileShader(fragShader);
        glGetShaderInfoLog(fragShader, 512, NULL, buffer);
        puts(buffer);
        
        shaderProgram = glCreateProgram();
        
        glAttachShader(shaderProgram, vertShader);
        glAttachShader(shaderProgram, fragShader);
        
        glBindAttribLocation(shaderProgram, GLKVertexAttribPosition, "positionAttrib");
        glBindAttribLocation(shaderProgram, GLKVertexAttribNormal, "normalAttrib");
        glBindAttribLocation(shaderProgram, GLKVertexAttribColor, "colorAttrib");
        
        glLinkProgram(shaderProgram);
        
        // cameraMatrixUniformLocation = glGetUniformLocation(_shaderProgram, "cameraMatrix");
        // modelMatrixUniformLocation = glGetUniformLocation(_shaderProgram, "modelMatrix");
        
        glGetProgramInfoLog(shaderProgram, 512, NULL, buffer);
        puts(buffer);
        
        glValidateProgram(shaderProgram);
        
        glGetProgramInfoLog(shaderProgram, 512, NULL, buffer);
        puts(buffer);
    });
    
    return shaderProgram;
}

-(void) draw {
    [self prepare];
    
    glBindVertexArrayOES(_vertexArray);
    
    if (_wireframe) {
        _effect.light0.enabled = NO;
        _effect.useConstantColor = YES;
        _effect.constantColor = GLKVector4Make(0, 0, 0, 1);
        [_effect prepareToDraw];
    
        glDisableVertexAttribArray(GLKVertexAttribNormal);
        glDisableVertexAttribArray(GLKVertexAttribColor);
        glDrawElements(GL_LINE_LOOP, _triangleCount, GL_UNSIGNED_SHORT, _indices);
    } else {
        _effect.light0.enabled = YES;
        _effect.useConstantColor = NO;
        [_effect prepareToDraw];
    
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glEnableVertexAttribArray(GLKVertexAttribColor);
        
        glDrawElements(_mode, _triangleCount, GL_UNSIGNED_SHORT, _indices);
    }
    
    glBindVertexArrayOES(0);
}

-(int) polyCount {
    return _triangleCount;
}

-(void) dealloc {
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    free(_vertexData);
    free(_indices);
}

-(INVCTMModel *) modelByTransforming:(GLKMatrix4)matrix {
    INVCTMModel *newModel = [self copy];
    newModel->_transform = GLKMatrix4Multiply(newModel->_transform, matrix);
    
    [newModel prepare];
    
    return newModel;
}

@end
