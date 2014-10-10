//
//  INVGlobalDataManager.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import EmpireMobileManager;

@interface INVGlobalDataManager : NSObject
@property (nonatomic,readonly)INVEmpireMobileClient* invServerClient;

+(id)sharedInstance;
@end
