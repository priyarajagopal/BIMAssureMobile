//
//  INVServerConfigCertsEqualSecurityPolicy.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/7/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVServerConfigCertsEqualSecurityPolicy.h"

@import Security;

@implementation INVServerConfigCertsEqualSecurityPolicy

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain {
    
    do {
        if (serverTrust == nil) break;
        
        OSStatus status = SecTrustEvaluate(serverTrust, NULL);
        if (status != errSecSuccess) break;
        
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
        if (certificate == nil) break;
        
        NSData *certificateData = (__bridge_transfer NSData *) SecCertificateCopyData(certificate);
        
        if (certificateData == nil) break;
        if (self.requiredCertificateData == nil) break;
        
        return [certificateData isEqualToData:self.requiredCertificateData];
    } while (0);
    
    return NO;
}

@end
