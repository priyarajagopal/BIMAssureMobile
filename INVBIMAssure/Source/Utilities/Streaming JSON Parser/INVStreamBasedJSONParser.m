#import "INVStreamBasedJSONParser.h"
#import "NSURLConnectionBlockDelegate.h"

#include <yajl/yajl_parse.h>

static NSString *const INVYajlErrorDomain = @"INVYajlErrorDomain";

@interface NSInputStreamBlockDelegate : NSObject<NSStreamDelegate>

@property (copy) void (^handleEvent)(NSStream *, NSStreamEvent);
@property id retainedSelf;

- (void)retainSelf;
- (void)releaseSelf;

@end

@implementation NSInputStreamBlockDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (self.handleEvent) {
        self.handleEvent(aStream, eventCode);
    }
}

- (void)retainSelf
{
    _retainedSelf = self;
}

- (void)releaseSelf
{
    _retainedSelf = nil;
}

@end

@interface INVStreamBasedJSONParser ()

@property NSMutableArray *pendingData;
@property NSThread *backgroundThread;

@property dispatch_semaphore_t hasDataSemaphore;
@property dispatch_queue_t consumeQueue;
@property yajl_handle yajlHandle;

- (int)yajl_callback_null;
- (int)yajl_callback_number:(const char *)str len:(size_t)length;
- (int)yajl_callback_string:(const char *)str len:(size_t)length;
- (int)yajl_callback_start_map;
- (int)yajl_callback_map_key:(const char *)str len:(size_t)length;
- (int)yajl_callback_end_map;
- (int)yajl_callback_start_array;
- (int)yajl_callback_end_array;

@end

static yajl_callbacks callbacks;

@implementation INVStreamBasedJSONParser

- (id)init
{
    if (self = [super init]) {
        _yajlHandle = yajl_alloc(&callbacks, NULL, (__bridge void *) self);
        yajl_config(_yajlHandle, yajl_allow_multiple_values, 1);

        _pendingData = [NSMutableArray new];
        _hasDataSemaphore = dispatch_semaphore_create(0);

        _consumeQueue = dispatch_queue_create("com.invicara.json.parser.consume", DISPATCH_QUEUE_SERIAL);
        _backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundThread) object:nil];

        [_backgroundThread start];
    }

    return self;
}

- (void)dealloc
{
    [_backgroundThread cancel];
    yajl_free(_yajlHandle);
}

- (void)_backgroundThread
{
    @autoreleasepool
    {
        while (YES) {
            if ([[NSThread currentThread] isCancelled])
                return;

            if (_pendingData.count == 0) {
                dispatch_semaphore_wait(_hasDataSemaphore, DISPATCH_TIME_FOREVER);
            }

            NSDictionary *toConsume = [_pendingData lastObject];
            [_pendingData removeLastObject];

            if (toConsume) {
                NSData *data = toConsume[@"data"];
                id callback = toConsume[@"callback"];

                yajl_status status = yajl_parse(_yajlHandle, [data bytes], [data length]);
                if (status != yajl_status_ok) {
                    uint8_t *errorMessage = yajl_get_error(_yajlHandle, 1, [data bytes], [data length]);

                    NSError *error = [[NSError alloc] initWithDomain:INVYajlErrorDomain
                                                                code:status
                                                            userInfo:@{
                                                                NSLocalizedDescriptionKey : @((const char *) errorMessage),
                                                            }];

                    yajl_free_error(_yajlHandle, errorMessage);

                    if (![self.delegate respondsToSelector:@selector(jsonParser:shouldRecoverFromError:)] ||
                        ![self.delegate jsonParser:self shouldRecoverFromError:error]) {
                        yajl_complete_parse(_yajlHandle);
                    }
                }

                if (callback) {
                    [callback invoke];
                }
            }
        }
    }
}

- (void)consume:(id)input
{
    if ([input isKindOfClass:[NSString class]]) {
        return [self _consumeString:input];
    }

    if ([input isKindOfClass:[NSURL class]]) {
        return [self _consumeURL:input];
    }

    if ([input isKindOfClass:[NSURLRequest class]]) {
        return [self _consumeURLRequest:input];
    }

    if ([input isKindOfClass:[NSData class]]) {
        return [self _consumeData:input];
    }

    if ([input isKindOfClass:[NSInputStream class]]) {
        return [self _consumeInputStream:input];
    }

    if ([input isKindOfClass:[NSDictionary class]]) {
        return [self _consumeDictionary:input];
    }

    if ([input isKindOfClass:[NSArray class]]) {
        return [self _consumeArray:input];
    }
}

- (void)_consumeString:(NSString *)string
{
    [self _consumeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)_consumeURL:(NSURL *)url
{
    [self _consumeURLRequest:[NSURLRequest requestWithURL:url]];
}

- (void)_consumeURLRequest:(NSURLRequest *)request
{
    dispatch_async(_consumeQueue, ^{
        dispatch_semaphore_t consumeSemaphore = dispatch_semaphore_create(0);

        NSURLConnectionBlockDelegate *blockDelegate = [NSURLConnectionBlockDelegate new];
        __weak typeof(blockDelegate) weakBlockDelegate = blockDelegate;
        [blockDelegate retainSelf];

        blockDelegate.didFailWithError = ^(NSURLConnection *connection, NSError *error) {
            INVLogError(@"NSURLConnection error: %@", error);

            [weakBlockDelegate releaseSelf];

            dispatch_semaphore_signal(consumeSemaphore);
        };

        blockDelegate.didRecieveData = ^(NSURLConnection *connection, NSData *data) {
            [self sendData:data complete:nil async:NO];
        };

        blockDelegate.didFinishLoading = ^(NSURLConnection *connection) {
            [weakBlockDelegate releaseSelf];

            dispatch_semaphore_signal(consumeSemaphore);
        };

        NSURLConnection *connection =
            [[NSURLConnection alloc] initWithRequest:request delegate:blockDelegate startImmediately:NO];

        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [connection start];

        dispatch_semaphore_wait(consumeSemaphore, DISPATCH_TIME_FOREVER);
    });
}

- (void)_consumeData:(NSData *)data
{
    [self sendData:data complete:nil async:YES];
}

- (void)_consumeInputStream:(NSInputStream *)inputStream
{
    NSInputStreamBlockDelegate *blockDelegate = [NSInputStreamBlockDelegate new];
    __weak typeof(blockDelegate) weakBlockDelegate = blockDelegate;
    [blockDelegate retainSelf];

    blockDelegate.handleEvent = ^(NSStream *stream, NSStreamEvent event) {
        if (event == NSStreamEventEndEncountered) {
            [stream close];

            [weakBlockDelegate releaseSelf];
            return;
        }

        if (event == NSStreamEventErrorOccurred) {
            [stream close];

            INVLogError(@"Stream error occurred!");
            [weakBlockDelegate releaseSelf];

            return;
        }

        if ([inputStream hasBytesAvailable]) {
            NSUInteger length = 1024;
            NSMutableData *buffer = [NSMutableData dataWithLength:length];

            if (![inputStream read:[buffer mutableBytes] maxLength:[buffer length]]) {
                INVLogError(@"NSInputStream read error");
                return;
            }

            [self sendData:buffer complete:nil async:NO];
        }
    };

    inputStream.delegate = blockDelegate;

    [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
}

- (void)_consumeDictionary:(NSDictionary *)dictionary
{
    // TODO: Consume dictionary
}

- (void)_consumeArray:(NSArray *)array
{
    // TODO: Consume array
}

- (void)sendData:(NSData *)data complete:(dispatch_block_t)complete async:(BOOL)async
{
    [_pendingData insertObject:@{ @"data" : data } atIndex:0];

    dispatch_semaphore_signal(_hasDataSemaphore);
}

#pragma mark - YAJL callbacks

- (int)yajl_callback_null
{
    if ([[self delegate] respondsToSelector:@selector(jsonParser:didReadValue:)]) {
        [[self delegate] jsonParser:self didReadValue:nil];
    }

    return 1;
}

- (int)yajl_callback_number:(const char *)str len:(size_t)length
{
    if ([[self delegate] respondsToSelector:@selector(jsonParser:didReadValue:)]) {
        NSString *string = [[NSString alloc] initWithBytes:(void *) str length:length encoding:NSUTF8StringEncoding];

        static NSNumberFormatter *numberFormatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            numberFormatter = [NSNumberFormatter new];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        });

        NSNumber *results = [numberFormatter numberFromString:string];
        [[self delegate] jsonParser:self didReadValue:results];
    }

    return 1;
}

- (int)yajl_callback_string:(const char *)str len:(size_t)length
{
    if ([[self delegate] respondsToSelector:@selector(jsonParser:didReadValue:)]) {
        NSString *string = [[NSString alloc] initWithBytes:(void *) str length:length encoding:NSUTF8StringEncoding];

        [[self delegate] jsonParser:self didReadValue:string];
    }

    return 1;
}

- (int)yajl_callback_start_map
{
    if ([[self delegate] respondsToSelector:@selector(jsonParserDidStartObject:)]) {
        [[self delegate] jsonParserDidStartObject:self];
    }

    return 1;
}

- (int)yajl_callback_map_key:(const char *)str len:(size_t)length
{
    if ([[self delegate] respondsToSelector:@selector(jsonParser:didReadKey:)]) {
        NSString *key = [[NSString alloc] initWithBytes:(void *) str length:length encoding:NSUTF8StringEncoding];

        [[self delegate] jsonParser:self didReadKey:key];
    }

    return 1;
}

- (int)yajl_callback_end_map
{
    if ([[self delegate] respondsToSelector:@selector(jsonParserDidEndObject:)]) {
        [[self delegate] jsonParserDidEndObject:self];
    }

    return 1;
}

- (int)yajl_callback_start_array
{
    if ([[self delegate] respondsToSelector:@selector(jsonParserDidStartArray:)]) {
        [[self delegate] jsonParserDidStartArray:self];
    }
    return 1;
}

- (int)yajl_callback_end_array
{
    if ([[self delegate] respondsToSelector:@selector(jsonParserDidEndArray:)]) {
        [[self delegate] jsonParserDidEndArray:self];
    }

    return 1;
}

@end

static int _yajl_callback_null(void *ctx)
{
    INVStreamBasedJSONParser *self = (__bridge INVStreamBasedJSONParser *) ctx;

    return [self yajl_callback_null];
}

static int _yajl_callback_number(void *ctx, const char *numberVal, size_t numberLen)
{
    INVStreamBasedJSONParser *self = (__bridge INVStreamBasedJSONParser *) ctx;

    return [self yajl_callback_number:numberVal len:numberLen];
}

static int _yajl_callback_string(void *ctx, const unsigned char *stringVal, size_t stringLen)
{
    INVStreamBasedJSONParser *self = (__bridge INVStreamBasedJSONParser *) ctx;

    return [self yajl_callback_string:(const char *) stringVal len:stringLen];
}

static int _yajl_callback_start_map(void *ctx)
{
    INVStreamBasedJSONParser *self = (__bridge INVStreamBasedJSONParser *) ctx;

    return [self yajl_callback_start_map];
}

static int _yajl_callback_map_key(void *ctx, const unsigned char *key, size_t stringLen)
{
    INVStreamBasedJSONParser *self = (__bridge INVStreamBasedJSONParser *) ctx;

    return [self yajl_callback_map_key:(const char *) key len:stringLen];
}

static int _yajl_callback_end_map(void *ctx)
{
    INVStreamBasedJSONParser *self = (__bridge INVStreamBasedJSONParser *) ctx;

    return [self yajl_callback_end_map];
}

static int _yajl_callback_start_array(void *ctx)
{
    INVStreamBasedJSONParser *self = (__bridge INVStreamBasedJSONParser *) ctx;

    return [self yajl_callback_start_array];
}

static int _yajl_callback_end_array(void *ctx)
{
    INVStreamBasedJSONParser *self = (__bridge INVStreamBasedJSONParser *) ctx;

    return [self yajl_callback_end_array];
}

static yajl_callbacks callbacks = {
    _yajl_callback_null, NULL, NULL, NULL, _yajl_callback_number, _yajl_callback_string, _yajl_callback_start_map,
    _yajl_callback_map_key, _yajl_callback_end_map, _yajl_callback_start_array, _yajl_callback_end_array,
};