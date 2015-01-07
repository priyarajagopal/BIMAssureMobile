//
//  INVServerConfigCertsEqualSecurityPolicy.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/7/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "AFSecurityPolicy.h"

@interface INVServerConfigCertsEqualSecurityPolicy : NSObject

@property NSData *requiredCertificateData;


@end
