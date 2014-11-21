#import <Foundation/Foundation.h>

@interface INVJSONCTMManager : NSObject

-(instancetype) initWithJSON:(NSData *) jsonData;
-(NSArray *) allModels;

@end
