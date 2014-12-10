@import Foundation;

#import "INVStreamBasedCTMParserChunk.h"
#import "INVStreamBasedCTMParserGLESCamera.h"

@interface INVStreamBasedCTMParserGLESMesh : NSObject

@property GLenum elementType;

-(id) initWithChunk:(INVStreamBasedCTMParserChunk *) chunk;

-(void) drawUsing:(unsigned) program;

@end
