@import Foundation;
@import GLKit;

// All lights are omnidirectional.
@interface INVStreamBasedCTMParserGLESLight : NSObject

@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector4 color;

@end

@interface INVStreamBasedCTMParserGLESCamera : NSObject

@property (nonatomic) GLKMatrix4 projectionTransform;
@property (nonatomic) GLKMatrix4 modelViewTransform;

// Max lights: 6
@property (nonatomic) NSArray *lights;

-(void) bindTo:(unsigned) program;

@end
