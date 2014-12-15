@import Foundation;
@import OpenCTM;

#import "INVStreamBasedCTMParserGLESCamera.h"
#import "GLKBBox.h"

extern int INVStreamBasedCTMParser_PositionAttributeLocation;
extern int INVStreamBasedCTMParser_NormalAttributeLocation;
extern int INVStreamBasedCTMParser_ColorAttributeLocation;

@interface INVStreamBasedCTMParserGLESMesh : NSObject

@property GLKBBox boundingBox;
@property GLenum elementType;
@property BOOL transparent;

-(id) initWithElementType:(GLenum) elementType
              transparent:(BOOL) transparent;

-(void) draw;
-(BOOL) appendCTMContext:(CTMcontext) context
              withMatrix:(GLKMatrix4) matrix
                andColor:(GLKVector4) color
          andBoundingBox:(GLKBBox) boundingBox;

-(void) printWastedSpace;

@end
