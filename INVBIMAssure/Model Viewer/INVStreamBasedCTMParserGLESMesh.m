#import "INVStreamBasedCTMParserGLESMesh.h"
#import "INVStreamBasedCTMParserChunkInternal.h"

@import OpenGLES;

static inline GLenum invChunkTypeToGLType(enum INVStreamBasedCTMParserChunkPrimitiveType primitiveType) {
    static GLenum types[] = {
        GL_TRIANGLES,
        GL_LINES,
        GL_POINTS
    };
    
    return types[primitiveType];
}

// Unsigned types
#define GL_TYPE_FROM_TYPE(type) _Generic(({ type t; t; }), \
    int8_t:   GL_BYTE,           \
    uint8_t:  GL_UNSIGNED_BYTE,  \
    int16_t:  GL_SHORT,          \
    uint16_t: GL_UNSIGNED_SHORT, \
    int32_t:  GL_INT,            \
    uint32_t: GL_UNSIGNED_INT,   \
    __fp16:   GL_HALF_FLOAT,     \
    float:    GL_FLOAT           \
)

@implementation INVStreamBasedCTMParserGLESMesh {
    GLenum _elementType;
    GLenum _indexType;
    
    GLenum _positionType;
    GLenum _normalType;
    GLenum _colorType;
    
    GLsizei _vertexCount;
    GLsizei _indexCount;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    NSData *_vertexData;
    NSData *_indexData;
    
    BOOL _isPrepared;
}

-(id) initWithChunk:(INVStreamBasedCTMParserChunk *)chunk {
    if (self = [super init]) {
        _elementType = invChunkTypeToGLType(chunk.primitiveType);
        _vertexData = [chunk vertexData];
        _indexData = [chunk indexData];
        
        _vertexCount = (GLsizei) [chunk vertexCount];
        _indexCount = (GLsizei) [_indexData length] / sizeof(index_index_type);
        
        _indexType = GL_TYPE_FROM_TYPE(index_index_type);
        
        _positionType = GL_TYPE_FROM_TYPE(vertex_position_element_type);
        _normalType   = GL_TYPE_FROM_TYPE(vertex_normal_element_type);
        _colorType    = GL_TYPE_FROM_TYPE(vertex_color_element_type);
    }
 
    return self;
}

-(void) dealloc {
    [self _destroyBuffers];
}

-(void) _prepareBuffers:(unsigned int) program {
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glGenBuffers(1, &_indexBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, [_vertexData length], [_vertexData bytes], GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, [_indexData length], [_indexData bytes], GL_STATIC_DRAW);
    
    GLuint positionIndex = glGetAttribLocation(program, "a_position");
    GLuint normalIndex = glGetAttribLocation(program, "a_normal");
    GLuint colorIndex = glGetAttribLocation(program, "a_color");
    
    glEnableVertexAttribArray(positionIndex);
    glVertexAttribPointer(
        positionIndex, 3, _positionType, GL_FALSE,
        sizeof(struct vertex_struct), (void *) offsetof(struct vertex_struct, position)
    );
    
    glEnableVertexAttribArray(normalIndex);
    glVertexAttribPointer(
        normalIndex, 3, _normalType, GL_FALSE,
        sizeof(struct vertex_struct), (void *) offsetof(struct vertex_struct, normal)
    );
    
    glEnableVertexAttribArray(colorIndex);
    glVertexAttribPointer(
        colorIndex, 4, _colorType, GL_FALSE,
        sizeof(struct vertex_struct), (void *) offsetof(struct vertex_struct, color)
    );
    
    glBindVertexArrayOES(0);
    
    _isPrepared = YES;
}

-(void) _destroyBuffers {
    glDeleteVertexArraysOES(1, &_vertexArray);
}

-(void) drawUsing:(unsigned int)program {
    if (!_isPrepared) {
        [self _prepareBuffers:program];
    }
    
    glBindVertexArrayOES(_vertexArray);
    
    glDrawElements(_elementType, _indexCount, _indexType, NULL);
    
    glBindVertexArrayOES(0);
}

@end
