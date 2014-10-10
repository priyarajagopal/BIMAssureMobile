//
//  INVGlobalDataManager.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVGlobalDataManager.h"
@import EmpireMobileManager;

@interface INVGlobalDataManager()
@property (nonatomic,readwrite)INVEmpireMobileClient* invServerClient;
@end

@implementation INVGlobalDataManager
+(id)sharedInstance {
  
    static INVGlobalDataManager* sharedInstance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class]alloc]init];
        if (sharedInstance) {
            sharedInstance.invServerClient = [INVEmpireMobileClient sharedInstanceWithXOSPassportServer:@"54.213.208.11" andPort:@"8080"];
            [sharedInstance.invServerClient configureWithEmpireManageServer:@"54.191.225.36" andPort:@"8080"];
        }
    });
    return sharedInstance;
    

}
@end
