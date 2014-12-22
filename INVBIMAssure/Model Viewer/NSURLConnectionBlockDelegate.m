#import "NSURLConnectionBlockDelegate.h"

@implementation NSURLConnectionBlockDelegate {
    id _retainedSelf;
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.didRecieveData) {
        self.didRecieveData(connection, data);
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.didFailWithError) {
        self.didFailWithError(connection, error);
    }
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (self.didRecieveResponse) {
        self.didRecieveResponse(connection, response);
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.didFinishLoading) {
        self.didFinishLoading(connection);
    }
}

-(void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (self.willSendRequestForAuthenticationChallenge) {
        self.willSendRequestForAuthenticationChallenge(connection, challenge);
    } else {
        [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
    }
}

-(void) retainSelf {
    _retainedSelf = self;
}

-(void) releaseSelf {
    _retainedSelf = nil;
}

@end
