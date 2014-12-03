#import <Foundation/Foundation.h>

@interface INVJSONCTMManager : NSObject

-(instancetype) initWithJSON:(NSData *) jsonData;
-(instancetype) initWithDictionary:(NSDictionary *) dictionary;
-(NSArray *) allModels;

@end
