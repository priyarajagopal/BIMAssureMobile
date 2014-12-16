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

static const GLKBBox GLKBBoxEmpty = {
    FLT_MAX, FLT_MAX,
    FLT_MIN, FLT_MIN
};

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

static inline float GLKVector3DistanceSquared(GLKVector3 vectorStart, GLKVector3 vectorEnd) {
    GLKVector3 difference = GLKVector3Subtract(vectorStart, vectorEnd);
    
    return fabsf(difference.v[0] * difference.v[0] + difference.v[1] * difference.v[1] + difference.v[2] * difference.v[2]);
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
    return
        (vector.x >= bbox.min.x && vector.x <= bbox.max.x) &&
        (vector.y >= bbox.min.y && vector.y <= bbox.max.y);
}

static inline BOOL GLKBBoxInterceptsRay(GLKBBox bbox, GLKVector3 rayPosition, GLKVector3 rayDirection, GLKVector3 *hitPoint) {
    GLKVector3 dirfrac;
    float t;
    
    // r.dir is unit direction vector of ray
    dirfrac.x = 1.0f / rayDirection.x;
    dirfrac.y = 1.0f / rayDirection.y;
    dirfrac.z = 1.0f / rayDirection.z;
    
    // lb is the corner of AABB with minimal coordinates - left bottom, rt is maximal corner
    // r.org is origin of ray
    float t1 = (bbox.min.x - rayPosition.x) * dirfrac.x;
    float t2 = (bbox.max.x - rayPosition.x) * dirfrac.x;
    float t3 = (bbox.min.y - rayPosition.y) * dirfrac.y;
    float t4 = (bbox.max.y - rayPosition.y) * dirfrac.y;
    float t5 = (bbox.min.z - rayPosition.z) * dirfrac.z;
    float t6 = (bbox.max.z - rayPosition.z) * dirfrac.z;
    
    float tmin = fmax(fmax(fmin(t1, t2), fmin(t3, t4)), fmin(t5, t6));
    float tmax = fmin(fmin(fmax(t1, t2), fmax(t3, t4)), fmax(t5, t6));
    
    // if tmax < 0, ray (line) is intersecting AABB, but whole AABB is behing us
    if (tmax < 0)
    {
        t = tmax;
        
        return false;
    }
    
    // if tmin > tmax, ray doesn't intersect AABB
    if (tmin > tmax)
    {
        t = tmax;
        
        return false;
    }
    
    t = tmin;
    
    if (hitPoint) {
        *hitPoint = GLKVector3Add(rayPosition, GLKVector3MultiplyScalar(rayDirection, t));
    }
    
    return true;
}