@import Foundation;

@import GLKit;
@import OpenGLES;
@import OpenCTM;

@interface INVCTMModel : NSObject<NSCopying>

@property GLKBaseEffect *effect;
@property BOOL wireframe;

-(id) initWithCTMData:(NSData *) data mode:(GLenum) drawMode color:(UIColor *) color;

-(void) loadWithCTMContext:(CTMcontext) context;
-(void) prepare;
-(void) draw;

-(INVCTMModel *) modelByTransforming:(GLKMatrix4) matrix;

@end
