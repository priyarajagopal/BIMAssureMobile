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
#warning pick up server config from plist file (eventually from json server)
            sharedInstance.invServerClient = [INVEmpireMobileClient sharedInstanceWithXOSPassportServer:@"54.68.45.16" andPort:@"8080"];
            [sharedInstance.invServerClient configureWithEmpireManageServer:@"54.191.53.48" andPort:@"8080"];
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
