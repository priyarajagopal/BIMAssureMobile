@import Foundation;
@import GLKit;

extern int INVStreamBasedCTMParserGLESCamera_ProjectionTransformUniformLocation;
extern int INVStreamBasedCTMParserGLESCamera_ModelViewTransformUniformLocation;
extern int INVStreamBasedCTMParserGLESCamera_NormalTransformUniformLocation;

extern int INVStreamBasedCTMParserGLESCamera_LightColorUniformLocation[6];
extern int INVStreamBasedCTMParserGLESCamera_LightPositionUniformLocation[6];

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

-(void) loadProgramNamed:(NSString *) programName;
-(void) bindProgram;

@end
