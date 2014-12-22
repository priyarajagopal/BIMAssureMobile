    //
//  INVGlobalDataManager.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVGlobalDataManager.h"
#import <FDKeychain/FDKeychain.h>

// NOTE: Using http rather than https as our SSL certs aren't properly set-up for this subdomain.
#define CONFIG_URL @"http://com.invicara.empire.dev-td.us-west-2.s3-us-west-2.amazonaws.com/System/Config/Startup.json?AWSAccessKeyId=AKIAIHLRHQHYGULUVRSA&Expires=1611118800&Signature=ok6Sk%2FBxOxw2ME92ak3c6jMwUss%3D"
#define _STRINGIFY(str) #str
#define STRINGIFY(str) _STRINGIFY(str)

#ifndef INV_DEPLOYMENT_NAME
#warning Deployment name not set!
#define INV_DEPLOYMENT_NAME nil
#endif

static BOOL getConfigFromURL(NSURL *url, NSString *__autoreleasing * passportServerUrl, NSString *__autoreleasing * empireManageServerUrl) {
    NSData *configData = [NSData dataWithContentsOfURL:url];
    if (configData == nil) {
        return NO;
    }
    
    NSDictionary *jsonConfig = [NSJSONSerialization JSONObjectWithData:configData options:0 error:NULL];

    NSString *deployName = @STRINGIFY(INV_DEPLOYMENT_NAME);
    NSString *defaultDeployName = jsonConfig[@"defaultdeploy"];
    
    NSDictionary *defaultDeploy = nil;
    NSDictionary *selectedDeploy = nil;
    
    for (NSDictionary *deploy in jsonConfig[@"deploys"] ) {
        if ([deployName isEqual:deploy[@"name"]]) {
            selectedDeploy = deploy;
        }
        
        if ([defaultDeployName isEqual:deploy[@"name"]]) {
            defaultDeploy = deploy;
        }
    }
    
    if (selectedDeploy == nil) {
        if (defaultDeploy == nil) {
            return NO;
        }
        
        selectedDeploy = defaultDeploy;
    }
    
    if (passportServerUrl) {
        *passportServerUrl = nil;
    }
    
    if (empireManageServerUrl) {
        *empireManageServerUrl = nil;
    }
    
    for (NSDictionary *server in selectedDeploy[@"servers"]) {
        NSString *serverName = server[@"server"];
        
        if ([serverName isEqual:@"xospassport"] && passportServerUrl) {
            *passportServerUrl = server[@"url"];
        }
        
        if ([serverName isEqualToString:@"empiremanage"] && empireManageServerUrl) {
            *empireManageServerUrl = server[@"url"];
        }
    }
    
    return YES;
}

@import EmpireMobileManager;

// Notifications
NSString* const INV_NotificationUserLogOutSuccess = @"userLogOutSuccess";
NSString* const INV_NotificationAccountLogOutSuccess = @"accountLogOutSuccess";
NSString* const INV_NotificationAccountSwitchSuccess = @"accountSwitchSuccess";

// Credentials Key
const NSString* INV_CredentialKeyEmail = @"email";
const NSString* INV_CredentialKeyPassword = @"password";

static NSString* const INV_CredentialsKeychainKey = @"BACredentials";
static NSString* const INV_DefaultAccountKeychainKey = @"BADefaultAccount";

@interface INVGlobalDataManager()
@property (nonatomic,readwrite)INVEmpireMobileClient* invServerClient;
@property (nonatomic,readwrite)NSDictionary* credentials;
@property (nonatomic,readwrite)NSNumber* defaultAccountId;
@end

@implementation INVGlobalDataManager

#pragma mark - public methods
+(INVGlobalDataManager*)sharedInstance {
  
    static INVGlobalDataManager* sharedInstance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class]alloc]init];
        
        if (sharedInstance) {
            NSString *xosPassportServer = nil;
            NSString *empireManageServer = nil;
            
            if (!getConfigFromURL([NSURL URLWithString:CONFIG_URL], &xosPassportServer, &empireManageServer)) {
                NSURL *url = [[NSBundle mainBundle] URLForResource:@"Startup" withExtension:@"json"];
                
                if (!getConfigFromURL(url, &xosPassportServer, &empireManageServer)) {
                    NSLog(@"Failed to load config from local file! Application probably will not work.");
                    return;
                }
            }
            
            sharedInstance.invServerClient = [INVEmpireMobileClient sharedInstanceWithXOSPassportServer:xosPassportServer andPort:@"8080"];
            [sharedInstance.invServerClient configureWithEmpireManageServer:empireManageServer andPort:@"8080"];
        }
    });
    
    return sharedInstance;
}

-(NSError*)saveCredentialsInKCForLoggedInUser:(NSString*)email withPassword:(NSString*)password {
    NSError* error;
    _credentials = @{INV_CredentialKeyEmail:email, INV_CredentialKeyPassword:password};
    [FDKeychain saveItem:_credentials forKey:INV_CredentialsKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
    if (error) {
        // silently ignoring error
        NSLog(@"%s. Failed with %@",__func__,error);
    }
    return error;
}

-(NSError*)deleteCurrentlySavedCredentialsFromKC {
    NSError* error;
    [FDKeychain deleteItemForKey:INV_CredentialsKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
    return error;
}

-(NSError*)saveDefaultAccountInKCForLoggedInUser:(NSNumber*)accountId {
    NSError* error;
    _defaultAccountId = accountId;
    [FDKeychain saveItem:_defaultAccountId forKey:INV_DefaultAccountKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
    if (error) {
        // silently ignoring error
        NSLog(@"%s. Failed with %@",__func__,error);
    }
    return error;
}

-(NSError*)deleteCurrentlySavedDefaultAccountFromKC {
    NSError* error;
    [FDKeychain deleteItemForKey:INV_DefaultAccountKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
    return error;
}

#pragma mark - public accessors
-(NSDictionary*) credentials {
    NSError* error;

    _credentials = [FDKeychain itemForKey:INV_CredentialsKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
    return _credentials;
}

-(NSNumber*)defaultAccountId {
    NSError* error;
    
    _defaultAccountId = [FDKeychain itemForKey:INV_DefaultAccountKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
    return _defaultAccountId;
}

-(NSString*)serviceIdentifierForKCStorage {
    return  [NSBundle bundleForClass:[self class]].bundleIdentifier;
}

@end
