//
//  INVGlobalDataManager.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVGlobalDataManager.h"
#import <FDKeychain/FDKeychain.h>

@import EmpireMobileManager;

const NSString* INV_BA_KEY_EMAIL = @"email";
const NSString* INV_BA_KEY_PASSWORD = @"password";

static NSString* const INV_BA_CREDENTIALS_KEY = @"BACredentials";

@interface INVGlobalDataManager()
@property (nonatomic,readwrite)INVEmpireMobileClient* invServerClient;
@property (nonatomic,readwrite)NSDictionary* credentials;
@end

@implementation INVGlobalDataManager

#pragma mark - public methods
+(INVGlobalDataManager*)sharedInstance {
  
    static INVGlobalDataManager* sharedInstance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class]alloc]init];
        if (sharedInstance) {
#pragma warning pick up server config from plist file (eventually from json server)
            sharedInstance.invServerClient = [INVEmpireMobileClient sharedInstanceWithXOSPassportServer:@"54.213.208.11" andPort:@"8080"];
            [sharedInstance.invServerClient configureWithEmpireManageServer:@"54.191.225.36" andPort:@"8080"];
        }
    });
    return sharedInstance;
    

}

-(NSError*)saveCredentialsForLoggedInUser:(NSString*)email withPassword:(NSString*)password {
    NSError* error;
    _credentials = @{INV_BA_KEY_EMAIL:email, INV_BA_KEY_PASSWORD:password};
    [FDKeychain saveItem:_credentials forKey:INV_BA_CREDENTIALS_KEY forService:[self serviceIdentifierForKCStorage] error:&error];
    if (error) {
        // silently ignoring error
        NSLog(@"%s. Failed with %@",__func__,error);
    }
    return error;
}

-(NSError*)deleteCredentialsForLoggedInUser {
    NSError* error;
    [FDKeychain deleteItemForKey:INV_BA_CREDENTIALS_KEY forService:[self serviceIdentifierForKCStorage] error:&error];
    return error;
}

#pragma mark - public accessors
-(NSDictionary*) credentials {
    NSString* bundleId = [NSBundle bundleForClass:[self class]].bundleIdentifier;
    NSError* error;

    _credentials = [FDKeychain itemForKey:INV_BA_CREDENTIALS_KEY forService:bundleId error:&error];
    return _credentials;
}

-(NSString*)serviceIdentifierForKCStorage {
    return  [NSBundle bundleForClass:[self class]].bundleIdentifier;
}

@end
