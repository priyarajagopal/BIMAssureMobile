#import "INVJSONCTMManager.h"
#import "INVCTMModel.h"

enum CtmTypeValues {
    CtmTypeTriangles,
    CtmTypeLines
};

static inline GLKMatrix4 parseMatrix(NSArray *asArray) {
    return GLKMatrix4Make(
        [asArray[0]  floatValue], [asArray[1]  floatValue], [asArray[2]  floatValue], [asArray[3]  floatValue],
        [asArray[4]  floatValue], [asArray[5]  floatValue], [asArray[6]  floatValue], [asArray[7]  floatValue],
        [asArray[8]  floatValue], [asArray[9]  floatValue], [asArray[10] floatValue], [asArray[11] floatValue],
        [asArray[12] floatValue], [asArray[13] floatValue], [asArray[14] floatValue], [asArray[15] floatValue]
    );
}

@interface _INVJSONSharedGeometry : NSObject 

@property NSString *id;
@property NSArray *models;

@end

@implementation _INVJSONSharedGeometry
@end

@implementation INVJSONCTMManager {
    NSDictionary *_jsonRepresentation;
    
    NSMutableDictionary *_sharedGeometries;
    NSMutableArray *_finalizedModels;
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
    }
    
    return self;
}

-(void) processSharedGeometries {
    _sharedGeometries = [NSMutableDictionary new];
    NSArray *sharedGeometries = _jsonRepresentation[@"sharedGeometries"];
    
    for (NSDictionary *geometry in sharedGeometries) {
        _INVJSONSharedGeometry *sharedGeom = [_INVJSONSharedGeometry new];
        sharedGeom.id = geometry[@"id"];
        
        NSMutableArray *models = [NSMutableArray new];
        NSArray *geometries = geometry[@"geometry"];
        
        for (NSDictionary *geom in geometries) {
            [models addObjectsFromArray:[self parseModels:geom]];
        }
        
        sharedGeom.models = [models copy];
        _sharedGeometries[sharedGeom.id] = sharedGeom;
    }
}

-(void) processOtherGeometrires {
    _finalizedModels = [NSMutableArray new];
    NSArray *normalGeometries = _jsonRepresentation[@"geometries"];
    
    for (NSDictionary *element in normalGeometries) {
        NSArray *elementGeometries = element[@"geometry"];
        
        for (NSDictionary *geom in elementGeometries) {
            [_finalizedModels addObjectsFromArray:[self parseModels:geom]];
        }
    }
}

-(NSArray *) parseModels:(NSDictionary *) geom {
    if (geom[@"ref"] != nil) {
        NSString *refId = geom[@"ref"];
        NSArray *matrix = geom[@"matrix"];
        
        _INVJSONSharedGeometry *sharedGeom = _sharedGeometries[refId];
        GLKMatrix4 parsedMatrix = parseMatrix(matrix);
        
        NSMutableArray *resultModels = [NSMutableArray new];
        for (INVCTMModel *model in sharedGeom.models) {
            [resultModels addObject:[model modelByTransforming:parsedMatrix]];
        }
        
        return [resultModels copy];
    } else if (geom[@"data"] != nil) {
        NSString *data = geom[@"data"];
        NSNumber *type = geom[@"type"];
        NSNumber *color = geom[@"color"];
        
        NSData *decoded = [[NSData alloc] initWithBase64EncodedString:data options:0];
        
        if (type == nil) type = @(CtmTypeTriangles);
        if (color == nil) color = @0;
        
        GLenum mode = [type intValue] == CtmTypeTriangles ? GL_TRIANGLES : GL_LINES;
        
        float red = ((color.intValue >> 16) & 0xFF) / 255.0f;
        float green = ((color.intValue >> 8) & 0xFF) / 255.0f;
        float blue = ((color.intValue >> 0) & 0xFF) / 255.0f;
        
        UIColor *asUIColor = [UIColor colorWithRed:red
                                             green:green
                                              blue:blue
                                             alpha:1];
        
        INVCTMModel *model = [[INVCTMModel alloc] initWithCTMData:decoded
                                                             mode:mode
                                                            color:asUIColor];
        
        return @[ model ];
    } else {
        NSLog(@"Unrecognized geom structure: %@", geom);
    }
    
    return nil;
}

-(NSArray *) allModels {
    return [[NSArray alloc] initWithArray:_finalizedModels copyItems:YES];
}

@end
