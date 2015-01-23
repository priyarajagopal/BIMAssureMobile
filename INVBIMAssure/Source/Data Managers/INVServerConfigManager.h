//
//  INVServerConfigManager.h
//  INVBIMAssure
//
//  Created by Richard Ross on 12/23/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INVServerConfigManager : NSObject

+(instancetype) instance;

-(void) loadConfigNamed:(NSString *) configName;
-(void) loadDefaultConfig;

-(NSString *) passportServerHost;
-(NSString *) passportServerPort;

-(NSString *) empireManageHost;
-(NSString *) empireManagePort;

-(NSString *) passportPasswordVerificationRegex;
-(NSString *) passportPasswordVerificationText;

@end
