//
//  INVStreamBasedCTMParser.m
//  INVBIMAssure
//
//  Created by Richard Ross on 12/8/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVStreamBasedCTMParser.h"
#import "INVStreamBasedJSONParser.h"
#import "GLKExtensions.h"

@import OpenCTM;
@import GLKit;
@import SceneKit;

struct _ctmReadNSDataUserData {
    __unsafe_unretained NSData *buffer;
    off_t offset;
};

static CTMuint _ctmReadNSData(void *buf, CTMuint size, void *userData) {
    struct _ctmReadNSDataUserData *ctmReadNSDataUserData = (struct _ctmReadNSDataUserData *) userData;
    
    CTMuint read = (CTMuint) MIN(size, [ctmReadNSDataUserData->buffer length] - ctmReadNSDataUserData->offset);
    
    memcpy(buf, [ctmReadNSDataUserData->buffer bytes] + ctmReadNSDataUserData->offset, read);
    ctmReadNSDataUserData->offset += read;
    
    return read;
}

@interface INVStreamBasedCTMParser()<INVStreamBasedJSONParserDelegate>
@end

@implementation INVStreamBasedCTMParser {
    INVStreamBasedJSONParser *_jsonParser;
    
    NSMutableDictionary *_sharedGeoms;
    
    INVStreamBasedCTMParserGLESMesh *_opaqueMesh;
    INVStreamBasedCTMParserGLESMesh *_transparentMesh;
    
    BOOL _isProcessingModels;
    BOOL _isProcessingModelGeometry;
    BOOL _isProcessingSharedGeoms;
    BOOL _isProcessingElements;
    BOOL _isProcessingElementGeometries;
    BOOL _isProcessingMatrix;
    BOOL _isProcessingBBox;
    
    NSString *_lastKey;
    
    NSString *_modelId;
    NSString *_modelFileId;
    
    NSString *_elementId;
    NSNumber *_elementType;
    
    NSString *_geometryRefId;
    NSNumber *_geometryType;
    NSNumber *_geometryColor;
    
    NSUInteger _geometryBBoxIndex;
    GLKBBox _geometryBBox;
    
    NSUInteger _geometryMatrixIndex;
    GLKMatrix4 _geometryMatrix;
    
    // This holds our vertices and indices
    CTMcontext _ctmContext;
}

-(id) init {
    if (self = [super init]) {
        _jsonParser = [[INVStreamBasedJSONParser alloc] init];
        _jsonParser.delegate = self;
        
        _sharedGeoms = [NSMutableDictionary new];
        
        _ctmContext = ctmNewContext(CTM_IMPORT);
    }
    
    return self;
}

-(void) dealloc {
    ctmFreeContext(_ctmContext);
    
    [self _destroySharedGeoms];
}

-(void) process:(id)source {
    [_jsonParser consume:source];
}

-(void) _appendGeometry:(CTMcontext) context
               withType:(NSNumber *) type
              andMatrix:(GLKMatrix4) matrix
               andColor:(NSNumber *) color
                andBBox:(GLKBBox) bbox
                  andId:(NSString *) id {
    if (color == nil) {
        color = @0xFFFFFF;
    }
    
    if (id == nil) {
        id = [[NSUUID UUID] UUIDString];
    }
    
    // NOTE: Support primtives other than triangles.
    if ([type intValue] != 0) return;
    
    float a = (([color intValue] >> 24) & 0xFF) / 255.0f;
    float r = (([color intValue] >> 16) & 0xFF) / 255.0f;
    float g = (([color intValue] >>  8) & 0xFF) / 255.0f;
    float b = (([color intValue] >>  0) & 0xFF) / 255.0f;
    
    // r = g = b = a = 1;
    
    if (a == 0 || a == 1) {
        a = 1;
    } else {
        a *= 0.5;
    }
    
    GLKVector4 glkColor = GLKVector4Make(r, g, b, a);
    
    INVStreamBasedCTMParserGLESMesh *mesh = (a == 1) ? _opaqueMesh : _transparentMesh;
    int times = 0;
    
    do {
        if (mesh == nil) {
            mesh = [[INVStreamBasedCTMParserGLESMesh alloc] initWithElementType:GL_TRIANGLES transparent:(a < 1)];
        }
    
        BOOL success = [mesh appendCTMContext:context
                               withMatrix:matrix
                                 andColor:glkColor
                            andBoundingBox:bbox
                                    andId:id];
    
        if (success) {
            break;
        }
        
        [self _completeMesh:mesh];
        mesh = nil;
        
        if (times > 1) {
            CTMuint vertCount = ctmGetInteger(context, CTM_VERTEX_COUNT);
            CTMuint triCount = ctmGetInteger(context, CTM_TRIANGLE_COUNT);
            
            NSLog(@"Failed to parse geometry with verts: %u, tris: %u", vertCount, triCount);
            break;
        }
        
        times++;
    } while (YES);
    
    if (mesh.transparent) {
        _transparentMesh = mesh;
    } else {
        _opaqueMesh = mesh;
    }
}

-(void) _completeMesh:(INVStreamBasedCTMParserGLESMesh *) mesh {
    if (mesh.transparent) {
        _transparentMesh = nil;
    } else {
        _opaqueMesh = nil;
    }
    
    // [mesh printWastedSpace];
    
    if ([self.delegate respondsToSelector:@selector(streamBasedCTMParser:didCompleteMesh:shouldStop:)]) {
        BOOL shouldStop = NO;
        [self.delegate streamBasedCTMParser:self didCompleteMesh:mesh shouldStop:&shouldStop];
    }
}

-(void) _processCurrentGeometry {
    if (_isProcessingSharedGeoms) {
        if (_sharedGeoms[_elementId] == nil) {
            _sharedGeoms[_elementId] = [NSMutableDictionary new];
            _sharedGeoms[_elementId][@"id"] = _elementId;
            _sharedGeoms[_elementId][@"contexts"] = [NSMutableArray new];
        }
        
        [_sharedGeoms[_elementId][@"contexts"] addObject:@{
            @"type": _geometryType,
            @"color": _geometryColor ?: [NSNull null],
            @"context": [NSValue valueWithPointer:_ctmContext]
        }];
        
        _ctmContext = ctmNewContext(CTM_IMPORT);
        
        return;
    }
    
    // Ignore 'space' elements.
    if ([_elementType intValue] == 1) {
        return;
    }
    
    if (_geometryRefId != nil) {
        NSArray *sharedGeometries = _sharedGeoms[_geometryRefId][@"contexts"];
        
        for (NSDictionary *geom in sharedGeometries) {
            NSNumber *type = geom[@"type"];
            NSNumber *color = geom[@"color"];
            CTMcontext context = [geom[@"context"] pointerValue];
            
            if ([color isKindOfClass:[NSNull class]]) {
                color = nil;
            }
            
            if (_geometryColor != nil) {
                color = _geometryColor;
            }
            
            [self _appendGeometry:context
                         withType:type
                        andMatrix:_geometryMatrix
                         andColor:color
                          andBBox:_geometryBBox
                            andId:_elementId];
        }
        
        return;
    }
    
    [self _appendGeometry:_ctmContext
                 withType:_geometryType
                andMatrix:_geometryMatrix
                 andColor:_geometryColor
                  andBBox:_geometryBBox
                    andId:_elementId];
}

-(void) _destroySharedGeoms {
    for (NSDictionary *geom in [_sharedGeoms allValues]) {
        for (NSDictionary *context in geom[@"contexts"]) {
            ctmFreeContext([context[@"context"] pointerValue]);
        }
    }
    
    _sharedGeoms = [NSMutableDictionary new];
}

#pragma mark - INVStreamBasedJSONParserDelegate

-(BOOL) jsonParser:(INVStreamBasedJSONParser *)parser shouldRecoverFromError:(NSError *)error {
    NSLog(@"JSON parser error: %@", error);
    
    return NO;
}

-(void) jsonParserDidStartObject:(INVStreamBasedJSONParser *)parser {
    if (_isProcessingModels && [_lastKey isEqualToString:@"modelGeometry"]) {
        _isProcessingModelGeometry = YES;
    }
    
    
    _lastKey = nil;
}

-(void) jsonParserDidEndObject:(INVStreamBasedJSONParser *)parser {
    if (_isProcessingElementGeometries) {
        [self _processCurrentGeometry];
        
        _geometryType = nil;
        _geometryColor = nil;
        _geometryRefId = nil;
        _geometryMatrixIndex = 0;
        _geometryMatrix = GLKMatrix4Identity;
        _geometryBBoxIndex = 0;
        _geometryBBox = GLKBBoxMake(GLKVector3Make(0, 0, 0), GLKVector3Make(0, 0, 0));
        
        ctmClearContext(_ctmContext);
    } else if (_isProcessingElements) {
        _elementId = nil;
        _elementType = nil;
    }
    
    if (!_isProcessingSharedGeoms && !_isProcessingElements) {
        if (_opaqueMesh) {
            [self _completeMesh:_opaqueMesh];
        }
        if (_transparentMesh) {
            [self _completeMesh:_transparentMesh];
        }
        
        [self _destroySharedGeoms];
        
        _isProcessingModelGeometry = NO;
    }
    
    _lastKey = nil;
}

-(void) jsonParserDidStartArray:(INVStreamBasedJSONParser *)parser {
    if ([_lastKey isEqualToString:@"models"]) {
        _isProcessingModels = YES;
    }
    
    if ([_lastKey isEqualToString:@"sharedGeometries"]) {
        _isProcessingSharedGeoms = YES;
    }
    
    if ([_lastKey isEqualToString:@"geometries"]) {
        _isProcessingElements = YES;
    }
    
    if ([_lastKey isEqualToString:@"geometry"]) {
        _isProcessingElementGeometries = YES;
    }
    
    if ([_lastKey isEqualToString:@"matrix"]) {
        _isProcessingMatrix = YES;
    }
    
    if ([_lastKey isEqualToString:@"box"]) {
        _isProcessingBBox = YES;
    }
    
    _lastKey = nil;
}

-(void) jsonParserDidEndArray:(INVStreamBasedJSONParser *)parser {
    if (_isProcessingMatrix) {
        _isProcessingMatrix = NO;
    } else if (_isProcessingBBox) {
        _isProcessingBBox = NO;
    } else if (_isProcessingElementGeometries) {
        _isProcessingElementGeometries = NO;
    } else if (_isProcessingElements) {
        _isProcessingElements = NO;
    } else if (_isProcessingSharedGeoms) {
        _isProcessingSharedGeoms = NO;
    } else if (_isProcessingModels) {
        _isProcessingModels = NO;
    }
    
    _lastKey = nil;
}

-(void) jsonParser:(INVStreamBasedJSONParser *)parser didReadKey:(id)key {
    _lastKey = key;
}

-(void) jsonParser:(INVStreamBasedJSONParser *)parser didReadValue:(id)value {
    if (_isProcessingMatrix) {
        _geometryMatrix.m[_geometryMatrixIndex] = [value floatValue];
        _geometryMatrixIndex++;
    } else if (_isProcessingBBox) {
        _geometryBBox.b[_geometryBBoxIndex] = [value floatValue];
        _geometryBBoxIndex++;
    } else if (_isProcessingElementGeometries) {
        if ([_lastKey isEqualToString:@"type"]) {
            _geometryType = value;
        }
        
        if ([_lastKey isEqualToString:@"color"]) {
            _geometryColor = value;
        }
        
        if ([_lastKey isEqualToString:@"ref"]) {
            _geometryRefId = value;
        }
        
        if ([_lastKey isEqualToString:@"data"]) {
            NSData *base64Decoded = [[NSData alloc] initWithBase64EncodedString:value options:0];
            struct _ctmReadNSDataUserData userData = { base64Decoded };
            
            ctmLoadCustom(_ctmContext, _ctmReadNSData, &userData);
        }
    } else if (_isProcessingElements || _isProcessingSharedGeoms) {
        if ([_lastKey isEqualToString:@"type"]) {
            _elementType = value;
        }
        
        if ([_lastKey isEqualToString:@"id"]) {
            _elementId = value;
        }
    }
    
    _lastKey = nil;
}

@end
