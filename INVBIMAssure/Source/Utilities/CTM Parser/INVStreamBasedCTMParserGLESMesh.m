#import "INVStreamBasedCTMParserGLESMesh.h"

#import <libkern/OSAtomic.h>

@import OpenGLES;

int INVStreamBasedCTMParser_PositionAttributeLocation;
int INVStreamBasedCTMParser_NormalAttributeLocation;
int INVStreamBasedCTMParser_ColorAttributeLocation;

// Max buffer size: 256kb. Any larger than that and we may have issues.
// Trying to allocate a contiguous region larger than that is asking for trouble.
#define MAX_VERTEX_BUFFER_SIZE (sizeof(struct vertex_struct) * MAX_VERTEX_COUNT)
#define MAX_INDEX_BUFFER_SIZE (sizeof(struct index_struct) * MAX_INDEX_COUNT)
#define MAX_VERTEX_COUNT 150000
#define MAX_INDEX_COUNT 625000

#define VERTEX_POSITION_GL_TYPE GL_FLOAT
#define VERTEX_NORMAL_GL_TYPE GL_FLOAT
#define VERTEX_COLOR_GL_TYPE GL_UNSIGNED_BYTE

typedef float vertex_position_element_type;
typedef float vertex_normal_element_type;
typedef uint8_t vertex_color_element_type;

#define INDEX_INDEX_GL_TYPE GL_UNSIGNED_INT

typedef uint32_t index_index_type;

struct __attribute__((packed)) vertex_struct {
    vertex_position_element_type position[3];
    vertex_normal_element_type normal[3];
    vertex_color_element_type color[4];
};

struct __attribute__((packed)) index_struct {
    index_index_type index;
};

@interface INVStreamBasedCTMParserGLESMeshElement : NSObject

@property NSString *elementId;

@property GLKBBox boundingBox;
@property NSRange vertexRange;
@property NSRange indexRange;

@end

@implementation INVStreamBasedCTMParserGLESMeshElement

- (id)init
{
    if (self = [super init]) {
        _boundingBox = GLKBBoxEmpty;
    }

    return self;
}

@end

@interface INVStreamBasedCTMParserGLESMesh ()

@property GLsizei vertexCount;
@property GLsizei indexCount;

@property GLuint vertexArray;
@property GLuint vertexBuffer;
@property GLuint indexBuffer;

@property struct vertex_struct *vertexPointer;
@property struct index_struct *indexPointer;

@property BOOL isPrepared;
@property BOOL isMapped;

@property NSMutableDictionary *elements;

@end

@implementation INVStreamBasedCTMParserGLESMesh

- (id)initWithElementType:(GLenum)elementType transparent:(BOOL)transparent
{
    if (self = [super init]) {
        _elementType = elementType;
        _transparent = transparent;

        _boundingBox = GLKBBoxEmpty;
        _elements = [NSMutableDictionary new];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self _prepareBuffers];
        });
    }

    return self;
}

- (void)dealloc
{
    [self _destroyBuffers];
}

- (void)_prepareBuffers
{
    if (_isPrepared)
        return;

    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);

    glGenBuffers(1, &_vertexBuffer);
    glGenBuffers(1, &_indexBuffer);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, MAX_INDEX_BUFFER_SIZE, NULL, GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, MAX_VERTEX_BUFFER_SIZE, NULL, GL_STATIC_DRAW);

    glEnableVertexAttribArray(INVStreamBasedCTMParser_PositionAttributeLocation);
    glVertexAttribPointer(INVStreamBasedCTMParser_PositionAttributeLocation, 3, VERTEX_POSITION_GL_TYPE, GL_FALSE,
        sizeof(struct vertex_struct), (void *) offsetof(struct vertex_struct, position));

    glEnableVertexAttribArray(INVStreamBasedCTMParser_NormalAttributeLocation);
    glVertexAttribPointer(INVStreamBasedCTMParser_NormalAttributeLocation, 3, VERTEX_NORMAL_GL_TYPE, GL_FALSE,
        sizeof(struct vertex_struct), (void *) offsetof(struct vertex_struct, normal));

    glEnableVertexAttribArray(INVStreamBasedCTMParser_ColorAttributeLocation);
    glVertexAttribPointer(INVStreamBasedCTMParser_ColorAttributeLocation, 4, VERTEX_COLOR_GL_TYPE, GL_TRUE,
        sizeof(struct vertex_struct), (void *) offsetof(struct vertex_struct, color));

    _vertexCount = 0;
    _indexCount = 0;

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);

    _isPrepared = YES;

    [self _mapBuffers];
}

- (void)_mapBuffers
{
    if (!_isPrepared)
        return;
    if (_isMapped)
        return;

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

    _vertexPointer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    _indexPointer = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    _isMapped = YES;
}

- (void)_unmapBuffers
{
    if (!_isPrepared)
        return;
    if (!_isMapped)
        return;

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

    glUnmapBufferOES(GL_ARRAY_BUFFER);
    glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);

    _vertexPointer = NULL;
    _indexPointer = NULL;

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    _isMapped = NO;
}

- (void)_destroyBuffers
{
    if (!_isPrepared)
        return;
    if (_isMapped) {
        [self _unmapBuffers];
    }

    glDeleteVertexArraysOES(1, &_vertexArray);

    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteBuffers(1, &_indexBuffer);
}

- (BOOL)appendCTMContext:(CTMcontext)ctmContext
              withMatrix:(GLKMatrix4)matrix
                andColor:(GLKVector4)color
          andBoundingBox:(GLKBBox)boundingBox
                   andId:(NSString *)elementId
{
    while (!_isMapped) {
        // wait
    }

    CTMuint ctmVertexCount = ctmGetInteger(ctmContext, CTM_VERTEX_COUNT);
    const CTMfloat *ctmVertices = ctmGetFloatArray(ctmContext, CTM_VERTICES);

    CTMuint ctmIndexCount = ctmGetInteger(ctmContext, CTM_TRIANGLE_COUNT) * 3;
    const CTMuint *ctmIndices = ctmGetIntegerArray(ctmContext, CTM_INDICES);

    if ((_vertexCount + ctmVertexCount) > MAX_VERTEX_COUNT || (_indexCount + ctmIndexCount) > MAX_INDEX_COUNT) {
        return NO;
    }

    long oldVertexEnd = _vertexCount;
    long oldIndexEnd = _indexCount;

    _vertexCount += ctmVertexCount;
    _indexCount += ctmIndexCount;

    INVStreamBasedCTMParserGLESMeshElement *meshElement = [INVStreamBasedCTMParserGLESMeshElement new];
    meshElement.elementId = elementId;
    meshElement.vertexRange = NSMakeRange(oldVertexEnd, ctmVertexCount);
    meshElement.indexRange = NSMakeRange(oldIndexEnd, ctmIndexCount);

    BOOL usingManualBBox = YES;
    // _boundingBox = GLKBBoxUnion(_boundingBox, boundingBox);

    if (!usingManualBBox) {
        meshElement.boundingBox = boundingBox;
    }

    for (int vertexIndex = 0; vertexIndex < ctmVertexCount; vertexIndex++) {
        GLKVector3 position = GLKVector3Make(
            ctmVertices[(vertexIndex * 3) + 0], ctmVertices[(vertexIndex * 3) + 1], ctmVertices[(vertexIndex * 3) + 2]);

        position = GLKMatrix4MultiplyVector3WithTranslation(matrix, position);

        _vertexPointer[oldVertexEnd + vertexIndex].position[0] = position.x;
        _vertexPointer[oldVertexEnd + vertexIndex].position[1] = position.y;
        _vertexPointer[oldVertexEnd + vertexIndex].position[2] = position.z;

        _vertexPointer[oldVertexEnd + vertexIndex].normal[0] = 0;
        _vertexPointer[oldVertexEnd + vertexIndex].normal[1] = 0;
        _vertexPointer[oldVertexEnd + vertexIndex].normal[2] = 0;

        _vertexPointer[oldVertexEnd + vertexIndex].color[0] = color.r * 0xFF;
        _vertexPointer[oldVertexEnd + vertexIndex].color[1] = color.g * 0xFF;
        _vertexPointer[oldVertexEnd + vertexIndex].color[2] = color.b * 0xFF;
        _vertexPointer[oldVertexEnd + vertexIndex].color[3] = color.a * 0xFF;
    }

    for (int primitiveIndex = 0; primitiveIndex < ctmIndexCount; primitiveIndex += 3) {
        struct index_struct *i0 = &_indexPointer[oldIndexEnd + primitiveIndex + 0];
        struct index_struct *i1 = &_indexPointer[oldIndexEnd + primitiveIndex + 1];
        struct index_struct *i2 = &_indexPointer[oldIndexEnd + primitiveIndex + 2];

        i0->index = (index_index_type)(ctmIndices[primitiveIndex + 0] + oldVertexEnd);
        i1->index = (index_index_type)(ctmIndices[primitiveIndex + 1] + oldVertexEnd);
        i2->index = (index_index_type)(ctmIndices[primitiveIndex + 2] + oldVertexEnd);

        struct vertex_struct *p0 = &_vertexPointer[i0->index];
        struct vertex_struct *p1 = &_vertexPointer[i1->index];
        struct vertex_struct *p2 = &_vertexPointer[i2->index];

        GLKVector3 v0 = GLKVector3Make(p0->position[0], p0->position[1], p0->position[2]);
        GLKVector3 v1 = GLKVector3Make(p1->position[0], p1->position[1], p1->position[2]);
        GLKVector3 v2 = GLKVector3Make(p2->position[0], p2->position[1], p2->position[2]);

        if (usingManualBBox) {
            meshElement.boundingBox = GLKBBoxUnionVector3(meshElement.boundingBox, v0);
            meshElement.boundingBox = GLKBBoxUnionVector3(meshElement.boundingBox, v1);
            meshElement.boundingBox = GLKBBoxUnionVector3(meshElement.boundingBox, v2);
        }

        GLKVector3 va = GLKVector3Subtract(v2, v1);
        GLKVector3 vb = GLKVector3Subtract(v0, v1);

        GLKVector3 normal = GLKVector3CrossProduct(va, vb);

        p0->normal[0] += normal.x;
        p0->normal[1] += normal.y;
        p0->normal[2] += normal.z;

        p1->normal[0] += normal.x;
        p1->normal[1] += normal.y;
        p1->normal[2] += normal.z;

        p2->normal[0] += normal.x;
        p2->normal[1] += normal.y;
        p2->normal[2] += normal.z;
    }

    for (int vertexIndex = 0; vertexIndex < ctmVertexCount; vertexIndex++) {
        struct vertex_struct *vertex = &_vertexPointer[oldVertexEnd + vertexIndex];

        GLKVector3 vector = GLKVector3Make(vertex->normal[0], vertex->normal[1], vertex->normal[2]);

        vector = GLKVector3Normalize(vector);

        vertex->normal[0] = vector.x;
        vertex->normal[1] = vector.y;
        vertex->normal[2] = vector.z;
    }

    _boundingBox = GLKBBoxUnion(_boundingBox, meshElement.boundingBox);

    if (meshElement.elementId) {
        _elements[meshElement.elementId] = meshElement;
    }

    return YES;
}

- (void)draw
{
    if (_isMapped) {
        [self _unmapBuffers];
    }

    glBindVertexArrayOES(_vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

    glDrawElements(_elementType, _indexCount, INDEX_INDEX_GL_TYPE, NULL);

    // glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    // glBindBuffer(GL_ARRAY_BUFFER, 0);
    // glBindVertexArrayOES(0);
}

- (NSString *)elementIdOfElementInterceptingRay:(GLKVector3)rayPosition direction:(GLKVector3)rayDirection
{
    // First see if the overall bounding box intercepts the array
    GLKVector3 hitPoint;
    // if (!GLKBBoxInterceptsRay(_boundingBox, rayPosition, rayDirection, &hitPoint)) {
    //     return nil;
    // }

    NSString *closestElement = nil;
    float closestDistSq = FLT_MAX;

    for (INVStreamBasedCTMParserGLESMeshElement *meshElement in [_elements allValues]) {
        if (!GLKBBoxInterceptsRay(meshElement.boundingBox, rayPosition, rayDirection, &hitPoint)) {
            continue;
        }

        float distanceSq = GLKVector3DistanceSquared(rayPosition, hitPoint);

        if (distanceSq < closestDistSq) {
            closestDistSq = distanceSq;
            closestElement = meshElement.elementId;
        }
    }

    return closestElement;
}

- (void)setColorOfElementWithId:(NSString *)elementId withColor:(GLKVector4)color
{
    [self _mapBuffers];

    INVStreamBasedCTMParserGLESMeshElement *element = _elements[elementId];

    if (element) {
        NSRange range = element.vertexRange;

        for (NSUInteger vertexIndex = 0; vertexIndex < range.length; vertexIndex++) {
            _vertexPointer[range.location + vertexIndex].color[0] = color.r * 0xFF;
            _vertexPointer[range.location + vertexIndex].color[1] = color.g * 0xFF;
            _vertexPointer[range.location + vertexIndex].color[2] = color.b * 0xFF;
            _vertexPointer[range.location + vertexIndex].color[3] = color.a * 0xFF;
        }
    }
}

- (void)printWastedSpace
{
    printf("vb: %zu\tib: %zu\n", (MAX_VERTEX_COUNT - _vertexCount) * sizeof(struct vertex_struct),
        (MAX_INDEX_COUNT - _indexCount) * sizeof(struct index_struct));
}

- (size_t)vertexCount
{
    return _vertexCount;
}

- (size_t)triangleCount
{
    return _indexCount / 3;
}

@end
