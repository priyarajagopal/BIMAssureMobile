#import <Foundation/Foundation.h>

@class INVStreamBasedJSONParser;

@protocol INVStreamBasedJSONParserDelegate<NSObject>
@optional

- (BOOL)jsonParser:(INVStreamBasedJSONParser *)parser shouldRecoverFromError:(NSError *)error;

- (void)jsonParser:(INVStreamBasedJSONParser *)parser didReadKey:(id)key;
- (void)jsonParser:(INVStreamBasedJSONParser *)parser didReadValue:(id)value;

- (void)jsonParserDidStartObject:(INVStreamBasedJSONParser *)parser;
- (void)jsonParserDidEndObject:(INVStreamBasedJSONParser *)parser;

- (void)jsonParserDidStartArray:(INVStreamBasedJSONParser *)parser;
- (void)jsonParserDidEndArray:(INVStreamBasedJSONParser *)parser;

@end

@interface INVStreamBasedJSONParser : NSObject

@property (weak) id<INVStreamBasedJSONParserDelegate> delegate;

/**
 Consume the input.

 Input can be an instance of
 NSString, NSURL, NSURLConnection, NSData, NSInputStream,
 NSDictionary or NSArray

 If a NSDictionary or NSArray is passed, it considers that as if it was its own JSON object.
 */
- (void)consume:(id)input;

@end
