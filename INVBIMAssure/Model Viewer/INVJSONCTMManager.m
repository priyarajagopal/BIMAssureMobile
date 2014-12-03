#import "INVJSONCTMManager.h"

@import SceneKit;
@import GLKit;
@import OpenCTM;

enum CtmTypeValues {
    CtmTypeTriangles,
    CtmTypeLines
};

static inline SCNMatrix4 parseMatrix(NSArray *asArray) {
    return (SCNMatrix4) {
        [asArray[0]  floatValue], [asArray[1]  floatValue], [asArray[2]  floatValue], [asArray[3]  floatValue],
        [asArray[4]  floatValue], [asArray[5]  floatValue], [asArray[6]  floatValue], [asArray[7]  floatValue],
        [asArray[8]  floatValue], [asArray[9]  floatValue], [asArray[10] floatValue], [asArray[11] floatValue],
        [asArray[12] floatValue], [asArray[13] floatValue], [asArray[14] floatValue], [asArray[15] floatValue]
    };
}

@implementation INVJSONCTMManager {
    NSDictionary *_jsonRepresentation;
    
    NSMutableDictionary *_sharedGeometries;
    NSMutableArray *_finalizedModels;
    
    CTMcontext _ctmContext;
}

-(id) initWithJSON:(NSData *)jsonData {
    return [self initWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:0
                                                                      error:NULL]];
}

-(id) initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init] ) {
        _jsonRepresentation = dictionary;
        _ctmContext = ctmNewContext(CTM_IMPORT);
        
        [self processSharedGeometries];
        [self processOtherGeometrires];
        
        ctmFreeContext(_ctmContext);
        _ctmContext = NULL;
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
            [results addObjectsFromArray:[self parseModels:geom]];
        }
        
        _sharedGeometries[geometry[@"id"]] = results;
    }
}

-(void) processOtherGeometrires {
    _finalizedModels = [NSMutableArray new];
    NSArray *normalGeometries = _jsonRepresentation[@"geometries"];
    
    for (NSDictionary *element in normalGeometries) {
        if (element[@"type"]) {
            continue;
        }
        
        NSArray *elementGeometries = element[@"geometry"];
        
        for (NSDictionary *geom in elementGeometries) {
            [_finalizedModels addObjectsFromArray:[self parseModels:geom]];
        }
    }
}


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

SCNVector3 scnVector3Subtract(SCNVector3 a, SCNVector3 b) {
    return SCNVector3Make(a.x - b.x, a.y - b.y, a.z - b.z);
}

SCNVector3 scnVector3CrossProduct(SCNVector3 a, SCNVector3 b) {
    return SCNVector3Make(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - b.y * a.x
    );
}

-(SCNGeometry *) ctmParse:(NSData *) data withType:(SCNGeometryPrimitiveType) type andColor:(UIColor *) color {
    struct _ctmReadNSDataUserData userData = { data };
    ctmLoadCustom(_ctmContext, _ctmReadNSData, &userData);
    
    int vertexCount = ctmGetInteger(_ctmContext, CTM_VERTEX_COUNT);
    const float *vertices = (const float *) ctmGetFloatArray(_ctmContext, CTM_VERTICES);
    float *normals = calloc(sizeof(float), vertexCount * 3);
    
    int triangleCount = ctmGetInteger(_ctmContext, CTM_TRIANGLE_COUNT);
    const CTMuint *indices = ctmGetIntegerArray(_ctmContext, CTM_INDICES);
    
    for (int triangleIndex = 0; triangleIndex < triangleCount; triangleIndex++) {
        int p1Index = indices[(triangleIndex * 3) + 0];
        int p2Index = indices[(triangleIndex * 3) + 1];
        int p3Index = indices[(triangleIndex * 3) + 2];
        
        const float *p1v = &vertices[p1Index * 3];
        const float *p2v = &vertices[p2Index * 3];
        const float *p3v = &vertices[p3Index * 3];
        
        GLKVector3 p1 = GLKVector3MakeWithArray((float *) p1v);
        GLKVector3 p2 = GLKVector3MakeWithArray((float *) p2v);
        GLKVector3 p3 = GLKVector3MakeWithArray((float *) p3v);
        
        GLKVector3 va = GLKVector3Subtract(p3, p2);
        GLKVector3 vb = GLKVector3Subtract(p1, p2);
        
        GLKVector3 normal = GLKVector3CrossProduct(va, vb);
        
        normals[(p1Index * 3) + 0] += normal.x;
        normals[(p1Index * 3) + 1] += normal.y;
        normals[(p1Index * 3) + 2] += normal.z;
        
        normals[(p2Index * 3) + 0] += normal.x;
        normals[(p2Index * 3) + 1] += normal.y;
        normals[(p2Index * 3) + 2] += normal.z;
        
        normals[(p3Index * 3) + 0] += normal.x;
        normals[(p3Index * 3) + 1] += normal.y;
        normals[(p3Index * 3) + 2] += normal.z;
    }
    
    // Normalize normals
    for (int normalIndex = 0; normalIndex < vertexCount; normalIndex++) {
        float x = normals[(normalIndex * 3) + 0];
        float y = normals[(normalIndex * 3) + 1];
        float z = normals[(normalIndex * 3) + 2];
        
        float normalized = 1.0f / sqrtf(x * x + y * y + z * z);
        
        normals[(normalIndex * 3) + 0] *= normalized;
        normals[(normalIndex * 3) + 1] *= normalized;
        normals[(normalIndex * 3) + 2] *= normalized;
    }
     
    NSData *vertexData = [NSData dataWithBytes:vertices length:sizeof(float) * vertexCount * 3];
    NSData *normalData = [NSData dataWithBytes:normals length:sizeof(float) * vertexCount * 3];
    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(CTMuint) * triangleCount * 3];
    
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithData:vertexData
                                                                       semantic:SCNGeometrySourceSemanticVertex
                                                                    vectorCount:vertexCount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:0
                                                                     dataStride:0];
    
    SCNGeometrySource *normalsSource = [SCNGeometrySource geometrySourceWithData:normalData
                                                                        semantic:SCNGeometrySourceSemanticNormal
                                                                     vectorCount:vertexCount
                                                                 floatComponents:YES
                                                             componentsPerVector:3
                                                               bytesPerComponent:sizeof(float)
                                                                      dataOffset:0
                                                                      dataStride:0];
     
    SCNGeometryElement *indicesElement = [SCNGeometryElement geometryElementWithData:indexData
                                                                       primitiveType:type
                                                                      primitiveCount:triangleCount
                                                                       bytesPerIndex:sizeof(CTMuint)];
    
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = color;
    
    material.lightingModelName = SCNLightingModelLambert;
    
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[ vertexSource, normalsSource ]
                                                    elements:@[ indicesElement ]];
    
    geometry.materials = @[ material ];
    
    free(normals);
    
    return geometry;
}


-(NSArray *) parseModels:(NSDictionary *) geom {
    if (geom[@"ref"] != nil) {
        NSString *refId = geom[@"ref"];
        NSArray *matrix = geom[@"matrix"];
        
        NSArray *nodes = _sharedGeometries[refId];
        NSMutableArray *results = [NSMutableArray new];
        
        for (SCNNode *node in nodes) {
            SCNNode *rotated = [node copy];
            rotated.transform = parseMatrix(matrix);
            
            [results addObject:rotated];
        }
        
        return results;
    } else if (geom[@"data"] != nil) {
        NSString *data = geom[@"data"];
        NSNumber *type = geom[@"type"];
        NSNumber *color = geom[@"color"];
        
        NSData *decoded = [[NSData alloc] initWithBase64EncodedString:data options:0];
        
        if (type == nil) type = @(CtmTypeTriangles);
        if (color == nil) color = @0xFFFFFF;
        
        SCNGeometryPrimitiveType primitiveType = [type intValue] == CtmTypeLines ? SCNGeometryPrimitiveTypeLine : SCNGeometryPrimitiveTypeTriangles;
        
        if (primitiveType == SCNGeometryPrimitiveTypeLine) return nil;
        
        float alpha = ((color.intValue >> 24) & 0xFF) / 255.0f;
        float red = ((color.intValue >> 16) & 0xFF) / 255.0f;
        float green = ((color.intValue >> 8) & 0xFF) / 255.0f;
        float blue = ((color.intValue >> 0) & 0xFF) / 255.0f;
        
        if (alpha == 0) alpha = 1;
        
        UIColor *uiColor = [UIColor colorWithRed:red
                                           green:green
                                            blue:blue
                                           alpha:alpha];
        
        // TODO - support color
        SCNGeometry *geometry = [self ctmParse:decoded withType:primitiveType andColor:uiColor];
        SCNNode *node = [SCNNode nodeWithGeometry:geometry];
        
        return @[ node ];
    } else {
        NSLog(@"Unrecognized geom structure: %@", geom);
    }
    
    return nil;
}

-(NSArray *) allModels {
    return [[NSArray alloc] initWithArray:_finalizedModels copyItems:NO];
}

@end
