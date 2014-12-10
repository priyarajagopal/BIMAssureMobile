//
//  INVStreamBasedCTMParserChunk.h
//  INVBIMAssure
//
//  Created by Richard Ross on 12/8/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

@import Foundation;
@import GLKit;
@import SceneKit;
@import OpenCTM;


@interface INVStreamBasedCTMParserChunk : NSObject

-(id) initWithPrimitiveType:(SCNGeometryPrimitiveType) primitiveType;

@property (readonly) SCNNode *toNode;
@property (readonly) SCNGeometryPrimitiveType primitiveType;
@property (readonly,getter=isMutable) BOOL mutable;

@property (readonly) NSInteger vertexCount;
@property (readonly) NSInteger primitiveCount;

@property (readonly) NSInteger maxVertexCount;
@property (readonly) NSInteger maxPrimitiveCount;

@property (readonly) size_t dataSize;

-(void) finalizeChunk;

-(BOOL) appendContext:(CTMcontext) ctmContext
           withMatrix:(GLKMatrix4) matrix
             andColor:(UIColor *) color;

@end