@import Foundation;

#import "INVStreamBasedCTMParserGLESCamera.h"
#import "GLKExtensions.h"
#import "OpenCTM/openctm.h"

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
          andBoundingBox:(GLKBBox) boundingBox
                   andId:(NSString *) elementId;

-(void) printWastedSpace;

-(NSString *) elementIdOfElementInterceptingRay:(GLKVector3) rayPosition
                                      direction:(GLKVector3) rayDirection;

-(void) setColorOfElementWithId:(NSString *) elementId
                      withColor:(GLKVector4) color;

-(size_t) vertexCount;
-(size_t) triangleCount;

@end
