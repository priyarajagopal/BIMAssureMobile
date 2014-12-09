#import "INVJSONCTMManager.h"

@import SceneKit;
@import GLKit;
@import OpenCTM;

enum CtmTypeValues {
    CtmTypeTriangles,
    CtmTypeLines
};

struct __attribute__((packed)) VertexStructure {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector4 color;
};

struct __attribute__((packed)) IndexStructure {
    uint32_t p1, p2, p3;
};

#define VERTEX_SIZE (sizeof(struct VertexStructure))
#define INDEX_SIZE (sizeof(struct IndexStructure))

struct _ctmReadNSDataUserData {
    __unsafe_unretained NSData *buffer;
    off_t offset;
};

CTMuint _ctmReadNSData(void *buf, CTMuint size, void *userData) {
    struct _ctmReadNSDataUserData *ctmReadNSDataUserData = (struct _ctmReadNSDataUserData *) userData;
    
    CTMuint read = (CTMuint) MIN(size, [ctmReadNSDataUserData->buffer length] - ctmReadNSDataUserData->offset);
    
    memcpy(buf, [ctmReadNSDataUserData->buffer bytes] + ctmReadNSDataUserData->offset, read);
    ctmReadNSDataUserData->offset += read;
    
    return read;
}

static inline GLKMatrix4 parseMatrix(NSArray *asArray) {
    if (asArray == nil) return GLKMatrix4Identity;
    
    return (GLKMatrix4) {
        [asArray[0]  floatValue], [asArray[1]  floatValue], [asArray[2]  floatValue], [asArray[3]  floatValue],
        [asArray[4]  floatValue], [asArray[5]  floatValue], [asArray[6]  floatValue], [asArray[7]  floatValue],
        [asArray[8]  floatValue], [asArray[9]  floatValue], [asArray[10] floatValue], [asArray[11] floatValue],
        [asArray[12] floatValue], [asArray[13] floatValue], [asArray[14] floatValue], [asArray[15] floatValue]
    };
}

static inline void applyVertexTransformation(NSMutableData *vertexData, GLKMatrix4 matrix) {
    NSInteger vertexCount = [vertexData length] / VERTEX_SIZE;
    struct VertexStructure *buffer = [vertexData mutableBytes];
    
    for (NSInteger index = 0; index < vertexCount; index++) {
        buffer[index].position = GLKMatrix4MultiplyVector3WithTranslation(matrix, buffer[index].position);
    }
}

static inline void applyIndexTransformation(NSMutableData *indexData, NSInteger indexOffset) {
    NSInteger triangleCount = [indexData length] / INDEX_SIZE;
    struct IndexStructure *buffer = [indexData mutableBytes];
    
    for (NSInteger index = 0; index < triangleCount; index++) {
        buffer[index].p1 += indexOffset;
        buffer[index].p2 += indexOffset;
        buffer[index].p3 += indexOffset;
    }
}

static inline void calculateNormals(NSMutableData *vertexData, NSMutableData *indexData) {
    struct VertexStructure *vertexPointer = [vertexData mutableBytes];
    struct IndexStructure *indexPointer = [indexData mutableBytes];
    
    NSInteger numVertices = [indexData length] / VERTEX_SIZE;
    NSInteger numTriangles = [indexData length] / INDEX_SIZE;
    
    // Note that we cannot memcpy the indices, as we are converting from 16 bit to 32 bit indices.
    for (int triIndex = 0; triIndex < numTriangles; triIndex++) {
        struct VertexStructure *p1 = &vertexPointer[indexPointer[triIndex].p1];
        struct VertexStructure *p2 = &vertexPointer[indexPointer[triIndex].p2];
        struct VertexStructure *p3 = &vertexPointer[indexPointer[triIndex].p3];
        
        GLKVector3 va = GLKVector3Subtract(p3->position, p2->position);
        GLKVector3 vb = GLKVector3Subtract(p1->position, p2->position);
        
        GLKVector3 normal = GLKVector3CrossProduct(va, vb);
    
        p1->normal = GLKVector3Add(p1->normal, normal);
        p2->normal = GLKVector3Add(p2->normal, normal);
        p3->normal = GLKVector3Add(p3->normal, normal);
    }
    
    // Finally, normalize the normals
    for (int vertIndex = 0; vertIndex < numVertices; vertIndex++) {
        vertexPointer[vertIndex].normal = GLKVector3Normalize(vertexPointer[vertIndex].normal);
    }
}

static NSDictionary *readCTMModel(NSData *model, NSInteger *currentIndexOffset) {
    CTMcontext readContext = ctmNewContext(CTM_IMPORT);
    
    struct _ctmReadNSDataUserData userData = (struct _ctmReadNSDataUserData) { model };
    ctmLoadCustom(readContext, &_ctmReadNSData, &userData);
    
    int numVertices = ctmGetInteger(readContext, CTM_VERTEX_COUNT);
    int numTriangles = ctmGetInteger(readContext, CTM_TRIANGLE_COUNT);
    
    NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:numVertices * VERTEX_SIZE];
    NSMutableData *indexData = [[NSMutableData alloc] initWithLength:numTriangles * INDEX_SIZE];
    
    struct VertexStructure *vertexPointer = [vertexData mutableBytes];
    struct IndexStructure *indexPointer = [indexData mutableBytes];
    
    const float *ctmVertexData = ctmGetFloatArray(readContext, CTM_VERTICES);
    const CTMuint *ctmIndexData = ctmGetIntegerArray(readContext, CTM_INDICES);
    
    for (int vertIndex = 0; vertIndex < numVertices; vertIndex++) {
        vertexPointer[vertIndex].position = GLKVector3MakeWithArray((float *) &ctmVertexData[vertIndex *3]);
        
        vertexPointer[vertIndex].normal = GLKVector3Make(0, 0, 0);
        vertexPointer[vertIndex].color = GLKVector4Make(1, 1, 1, 1);
    }
    
    // Note that we cannot memcpy the indices, as we are converting from 16 bit to 32 bit indices.
    for (int triIndex = 0; triIndex < numTriangles; triIndex++) {
        indexPointer[triIndex].p1 = ctmIndexData[(triIndex * 3) + 0];
        indexPointer[triIndex].p2 = ctmIndexData[(triIndex * 3) + 1];
        indexPointer[triIndex].p3 = ctmIndexData[(triIndex * 3) + 2];
    }
    
    if (currentIndexOffset) {
        applyIndexTransformation(indexData, *currentIndexOffset);
        *currentIndexOffset += numVertices;
    }
    
    ctmFreeContext(readContext);
    
    return @{
        @"vertices": vertexData,
        @"indices": indexData
    };
}

static NSArray *readModelsFrom(NSDictionary *geom, NSDictionary *shared, NSInteger *currentIndexOffset) {
    if (geom[@"ref"] != nil) {
        NSString *refId = geom[@"ref"];
        NSArray *matrix = geom[@"matrix"];
        
        NSArray *nodes = shared[refId];
        NSMutableArray *results = [NSMutableArray new];
        
        GLKMatrix4 parsedMatrix = parseMatrix(matrix);
        
        for (NSDictionary *model in nodes) {
            NSMutableData *vertexData = [model[@"vertices"] mutableCopy];
            NSMutableData *indexData = [model[@"indices"] mutableCopy];
            
            applyVertexTransformation(vertexData, parsedMatrix);
            applyIndexTransformation(indexData, *currentIndexOffset);
            
            *currentIndexOffset += ([vertexData length] / VERTEX_SIZE);
            
            [results addObject:@{
                @"vertices": vertexData,
                @"indices": indexData
            }];
        }
        
        return results;
    } else if (geom[@"data"] != nil) {
        NSString *data = geom[@"data"];
        NSNumber *type = geom[@"type"];
        
        if ([type isEqual:@1]) {
            // Ignore lines right now
            return nil;
        }
        
        NSData *decoded = [[NSData alloc] initWithBase64EncodedString:data options:0];
        return @[ readCTMModel(decoded, currentIndexOffset) ];
    } else {
        NSLog(@"Unrecognized geom structure: %@", geom);
    }
    
    return nil;
}

@implementation INVJSONCTMManager {
    NSDictionary *_jsonRepresentation;
    
    NSMutableDictionary *_sharedGeometries;
    
    CTMcontext _ctmContext;
    
    NSMutableData *_trianglesVertexData;
    NSMutableData *_trianglesIndexData;
    
    SCNNode *_trianglesNode;
    
    // TODO - make lines work
    NSMutableData *_linesVertexData;
    NSMutableData *_linesIndexData;
}

-(id) initWithJSON:(NSData *)jsonData {
    return [self initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:0
                                                                      error:NULL]];
}

-(id) initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init] ) {
        _jsonRepresentation = dictionary;
        
        [self processSharedGeometries];
        [self processOtherGeometrires];
        [self createNode];
    }
    
    return self;
}

-(void) processSharedGeometries {
    _sharedGeometries = [NSMutableDictionary new];
    NSArray *sharedGeometries = _jsonRepresentation[@"sharedGeometries"];
    
    for (NSDictionary *geometry in sharedGeometries) {
        NSMutableArray *results = [NSMutableArray new];
        NSArray *geometries = geometry[@"geometry"];
        
        for (NSDictionary *geom in geometries) {
            NSString *data = geom[@"data"];
            NSData *decoded = [[NSData alloc] initWithBase64EncodedString:data options:0];
            
            [results addObject:readCTMModel(decoded, NULL)];
        }
        
        _sharedGeometries[geometry[@"id"]] = results;
    }
}

-(void) processOtherGeometrires {
    _trianglesVertexData = [NSMutableData new];
    _trianglesIndexData = [NSMutableData new];
    
    NSInteger currentIndexOffset = 0;
    NSArray *normalGeometries = _jsonRepresentation[@"geometries"];
    
    for (NSDictionary *element in normalGeometries) {
        if (element[@"type"]) {
            continue;
        }
        
        NSArray *elementGeometries = element[@"geometry"];
        
        for (NSDictionary *geom in elementGeometries) {
            // TODO: Add support for lines
            if ([geom[@"type"] isEqual:@1]) continue;
            
            NSArray *models = readModelsFrom(geom, _sharedGeometries, &currentIndexOffset);
            
            if (currentIndexOffset < 0) {
                NSLog(@"Warning! Index offset potentially overflowed!\n");
            }
            
            for (NSDictionary *model in models) {
                [_trianglesVertexData appendData:model[@"vertices"]];
                [_trianglesIndexData appendData:model[@"indices"]];
            }
        }
    }
    
    calculateNormals(_trianglesVertexData, _trianglesIndexData);
}

-(void) createNode {
    NSInteger vertexCount = [_trianglesVertexData length] / VERTEX_SIZE;
    NSInteger trianglesCount = [_trianglesIndexData length] / INDEX_SIZE;
    
    SCNGeometrySource *positionSource = [SCNGeometrySource geometrySourceWithData:_trianglesVertexData
                                                                         semantic:SCNGeometrySourceSemanticVertex
                                                                      vectorCount:vertexCount
                                                                  floatComponents:YES
                                                              componentsPerVector:3
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(struct VertexStructure, position)
                                                                       dataStride:sizeof(struct VertexStructure)];
    
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:_trianglesVertexData
                                                                        semantic:SCNGeometrySourceSemanticNormal
                                                                     vectorCount:vertexCount
                                                                 floatComponents:YES
                                                             componentsPerVector:3
                                                               bytesPerComponent:sizeof(float)
                                                                      dataOffset:offsetof(struct VertexStructure, normal)
                                                                      dataStride:sizeof(struct VertexStructure)];
    
    SCNGeometrySource *colorSource = [SCNGeometrySource geometrySourceWithData:_trianglesVertexData
                                                                      semantic:SCNGeometrySourceSemanticColor
                                                                   vectorCount:vertexCount
                                                               floatComponents:YES
                                                           componentsPerVector:4
                                                             bytesPerComponent:sizeof(float)
                                                                    dataOffset:offsetof(struct VertexStructure, color)
                                                                    dataStride:sizeof(struct VertexStructure)];
    
    SCNGeometryElement *trianglesElement = [SCNGeometryElement geometryElementWithData:_trianglesIndexData
                                                                         primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                                        primitiveCount:trianglesCount
                                                                         bytesPerIndex:sizeof(uint32_t)];
    
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [UIColor whiteColor];
    
    SCNGeometry *trianglesGeometry = [SCNGeometry geometryWithSources:@[ positionSource, normalSource, colorSource ]
                                                             elements:@[ trianglesElement ]];
    
    [trianglesGeometry insertMaterial:material atIndex:0];
    
    _trianglesNode = [SCNNode nodeWithGeometry:trianglesGeometry];
}

-(NSArray *) allModels {
    return @[ _trianglesNode ];
}

@end
