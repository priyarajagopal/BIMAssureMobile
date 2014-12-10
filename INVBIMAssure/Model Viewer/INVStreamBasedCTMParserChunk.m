//
//  INVStreamBasedCTMParserChunk.m
//  INVBIMAssure
//
//  Created by Richard Ross on 12/8/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVStreamBasedCTMParserChunk.h"
#import "INVStreamBasedCTMParserChunkInternal.h"

@import OpenGLES;

static NSString *const vertexShader = @"";

static inline int indiciesPerPrimitiveType(enum INVStreamBasedCTMParserChunkPrimitiveType primitiveType) {
    int indexCounts[] = {
        3, 2, 1
    };
    
    return indexCounts[primitiveType];
}

// Max buffer size: 64mb. Any larger than that and we may have issues.
// Trying to allocate a contiguous region larger than that is asking for trouble.
#define MAX_BUFFER_SIZE (64 * 1024 * 1024)
#define MAX_VERTEX_COUNT UINT16_MAX
#define MAX_INDEX_COUNT UINT32_MAX

@implementation INVStreamBasedCTMParserChunk {
    NSInteger _indicesPerPrimitive;
    
    NSMutableData *_vertexData;
    NSMutableData *_indexData;
}

-(id) initWithPrimitiveType:(enum INVStreamBasedCTMParserChunkPrimitiveType) primitiveType {
    if (self = [super init]) {
        _primitiveType = primitiveType;
        _mutable = YES;
        
        _indicesPerPrimitive = indiciesPerPrimitiveType(primitiveType);
        
        _vertexData = [NSMutableData new];
        _indexData = [NSMutableData new];
    }
    
    return self;
}

-(NSInteger) vertexCount {
    return [_vertexData length] / sizeof(struct vertex_struct);
}

-(NSInteger) primitiveCount {
    return [_indexData length] / (sizeof(struct index_struct) * _indicesPerPrimitive);
}

-(NSInteger) maxVertexCount {
    return MAX_VERTEX_COUNT;
}

-(NSInteger) maxPrimitiveCount {
    return MAX_INDEX_COUNT / _indicesPerPrimitive;
}

-(NSData *) vertexData {
    if (_mutable) return nil;
    
    return _vertexData;
}

-(NSData *) indexData {
    if (_mutable) return nil;
    
    return _indexData;
}

-(size_t) dataSize {
    return [_vertexData length] + [_indexData length];
}

-(void) finalizeChunk {
    _mutable = NO;
}

-(BOOL) appendContext:(CTMcontext)ctmContext withMatrix:(GLKMatrix4)matrix andColor:(UIColor *) color {
    @synchronized (self) {
        if (!_mutable) {
            return NO;
        }
    
        CTMuint ctmVertexCount = ctmGetInteger(ctmContext, CTM_VERTEX_COUNT);
        const CTMfloat *ctmVertices = ctmGetFloatArray(ctmContext, CTM_VERTICES);
    
        CTMuint ctmPrimitiveCount = ctmGetInteger(ctmContext, CTM_TRIANGLE_COUNT);
        const CTMuint *ctmIndices = ctmGetIntegerArray(ctmContext, CTM_INDICES);
    
        if ((self.vertexCount + ctmVertexCount) > self.maxVertexCount ||
            (self.primitiveCount + ctmPrimitiveCount) > self.maxPrimitiveCount) {
            return NO;
        }
    
        size_t requiredVertexBytes = (ctmVertexCount * sizeof(struct vertex_struct));
        size_t requiredIndexBytes = (ctmPrimitiveCount * sizeof(struct index_struct) * _indicesPerPrimitive);
    
        NSUInteger oldVertexEnd = [self vertexCount];
        NSUInteger oldIndexEnd = [self primitiveCount] * _indicesPerPrimitive;
    
        if (([_vertexData length] + requiredVertexBytes) > MAX_BUFFER_SIZE || ([_indexData length] + requiredIndexBytes) > MAX_BUFFER_SIZE) {
            return NO;
        }
    
        [_vertexData increaseLengthBy:requiredVertexBytes];
        [_indexData increaseLengthBy:requiredIndexBytes];
    
        struct vertex_struct *vertexPointer = [_vertexData mutableBytes];
        struct index_struct *indexPointer = [_indexData mutableBytes];
    
        CGFloat colorR, colorG, colorB, colorA;
        [color getRed:&colorR green:&colorG blue:&colorB alpha:&colorA];
    
        for (int vertexIndex = 0; vertexIndex < ctmVertexCount; vertexIndex++) {
            GLKVector3 position = GLKVector3MakeWithArray((float *) &ctmVertices[vertexIndex * 3]);
            position = GLKMatrix4MultiplyVector3WithTranslation(matrix, position);
            
            vertexPointer[oldVertexEnd + vertexIndex].position[0] = position.x;
            vertexPointer[oldVertexEnd + vertexIndex].position[1] = position.y;
            vertexPointer[oldVertexEnd + vertexIndex].position[2] = position.z;
        
            vertexPointer[oldVertexEnd + vertexIndex].normal[0] = 0;
            vertexPointer[oldVertexEnd + vertexIndex].normal[1] = 0;
            vertexPointer[oldVertexEnd + vertexIndex].normal[2] = 0;
        
            vertexPointer[oldVertexEnd + vertexIndex].color[0] = colorR;
            vertexPointer[oldVertexEnd + vertexIndex].color[1] = colorG;
            vertexPointer[oldVertexEnd + vertexIndex].color[2] = colorB;
            vertexPointer[oldVertexEnd + vertexIndex].color[3] = colorA;
        }
    
        for (int primitiveIndex = 0; primitiveIndex < ctmPrimitiveCount; primitiveIndex++) {
            struct index_struct *i0 = &indexPointer[oldIndexEnd + (primitiveIndex * _indicesPerPrimitive) + 0];
            struct index_struct *i1 = &indexPointer[oldIndexEnd + (primitiveIndex * _indicesPerPrimitive) + 1];
            struct index_struct *i2 = &indexPointer[oldIndexEnd + (primitiveIndex * _indicesPerPrimitive) + 2];
            
            i0->index = (index_index_type) (ctmIndices[(primitiveIndex * _indicesPerPrimitive) + 0] + oldVertexEnd);
            i1->index = (index_index_type) (ctmIndices[(primitiveIndex * _indicesPerPrimitive) + 1] + oldVertexEnd);
            i2->index = (index_index_type) (ctmIndices[(primitiveIndex * _indicesPerPrimitive) + 2] + oldVertexEnd);
            
            struct vertex_struct *p0 = &vertexPointer[i0->index];
            struct vertex_struct *p1 = &vertexPointer[i1->index];
            struct vertex_struct *p2 = &vertexPointer[i2->index];
            
            GLKVector3 v0 = GLKVector3Make(p0->position[0], p0->position[1], p0->position[2]);
            GLKVector3 v1 = GLKVector3Make(p1->position[0], p1->position[1], p1->position[2]);
            GLKVector3 v2 = GLKVector3Make(p2->position[0], p2->position[1], p2->position[2]);
            
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
            struct vertex_struct *vertex = &vertexPointer[oldVertexEnd + vertexIndex];
            
            GLKVector3 vector = GLKVector3Make(
                vertex->position[0],
                vertex->position[1],
                vertex->position[2]
            );
            vector = GLKVector3Normalize(vector);
            
            vertex->normal[0] = vector.x;
            vertex->normal[1] = vector.y;
            vertex->normal[2] = vector.z;
        }
    
        return YES;
    }
}

@end
