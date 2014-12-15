//
//  bbox.h
//  INVBIMAssure
//
//  Created by Richard Ross on 12/12/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#pragma once

@import GLKit;

typedef union {
    struct {
        GLKVector3 min;
        GLKVector3 max;
    };
    
    float b[6];
} GLKBBox;

static inline GLKBBox GLKBBoxMake(GLKVector3 min, GLKVector3 max) {
    return (GLKBBox) { min, max };
}

static inline GLKBBox GLKBBoxUnion(GLKBBox left, GLKBBox right) {
    return (GLKBBox) {
        GLKVector3Minimum(GLKVector3Minimum(left.min, right.min), GLKVector3Minimum(left.max, right.max)),
        GLKVector3Maximum(GLKVector3Maximum(left.min, right.min), GLKVector3Maximum(left.max, right.max)),
    };
}

static inline GLKBBox GLKBBoxUnionVector3(GLKBBox left, GLKVector3 right) {
    return (GLKBBox) {
        GLKVector3Minimum(left.min, right),
        GLKVector3Maximum(left.max, right)
    };
}

static inline GLKVector3 GLKBBoxCenter(GLKBBox bbox) {
    GLKVector3 difference = GLKVector3Subtract(bbox.max, bbox.min);
    difference = GLKVector3DivideScalar(difference, 2);
    difference = GLKVector3Add(difference, bbox.min);
    
    return difference;
}

static inline GLKVector3 GLKBBoxSize(GLKBBox bbox) {
    return GLKVector3Subtract(bbox.max, bbox.min);
}

static inline BOOL GLKBBoxContains(GLKBBox bbox, GLKVector3 vector) {
    return NO;
}