#import <Foundation/Foundation.h>

@interface NSURLConnectionBlockDelegate : NSObject<NSURLConnectionDataDelegate>

@property (copy) void (^didRecieveData)(NSURLConnection *, NSData *);
@property (copy) void (^didFailWithError)(NSURLConnection *, NSError *);
@property (copy) void (^didRecieveResponse)(NSURLConnection *, NSURLResponse *);
@property (copy) void (^didFinishLoading)(NSURLConnection *);
@property (copy) void (^willSendRequestForAuthenticationChallenge)(NSURLConnection *, NSURLAuthenticationChallenge *);

- (void)retainSelf;
- (void)releaseSelf;

@end