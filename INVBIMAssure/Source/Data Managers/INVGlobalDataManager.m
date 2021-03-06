//
//  INVGlobalDataManager.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVGlobalDataManager.h"
#import <FDKeychain/FDKeychain.h>
#import <AFNetworking/AFNetworking.h>

#import "INVServerConfigManager.h"

@import EmpireMobileManager;

// Notifications
NSString *const INV_NotificationUserLogOutSuccess = @"userLogOutSuccess";
NSString *const INV_NotificationAccountLogOutSuccess = @"accountLogOutSuccess";
NSString *const INV_NotificationAccountSwitchSuccess = @"accountSwitchSuccess";

// Credentials Key
const NSString *INV_CredentialKeyEmail = @"email";
const NSString *INV_CredentialKeyPassword = @"password";

static NSString *const INV_CredentialsKeychainKey = @"BACredentials";
static NSString *const INV_DefaultAccountKeychainKey = @"BADefaultAccount";

@interface INVGlobalDataManager ()
@property (nonatomic, readwrite) INVEmpireMobileClient *invServerClient;
@property (nonatomic, readwrite) NSDictionary *credentials;
@property (nonatomic, readwrite) NSNumber *defaultAccountId;
@property (nonatomic, readwrite) BOOL rememberMeOptionSelected;
@property (nonatomic, strong) NSMutableSet *editedAccounts;
@property (nonatomic, strong) NSMutableSet *editedProjects;
@property (nonatomic, strong) NSMutableSet *editedUsers;
@end

@implementation INVGlobalDataManager

#pragma mark - public methods
+ (INVGlobalDataManager *)sharedInstance
{
    static INVGlobalDataManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];

        if (sharedInstance) {
            INVServerConfigManager *configManager = [INVServerConfigManager instance];
            if (sharedInstance.credentials) {
                sharedInstance.rememberMeOptionSelected = YES;
            }
            else {
                sharedInstance.rememberMeOptionSelected = NO;
            }

            [configManager loadDefaultConfig];

            sharedInstance.invServerClient =
                [INVEmpireMobileClient sharedInstanceWithXOSPassportServer:[configManager passportServerHost]
                                                                   andPort:[configManager passportServerPort]];

            [sharedInstance.invServerClient configureWithEmpireManageServer:[configManager empireManageHost]
                                                                    andPort:[configManager empireManagePort]];
            
            [sharedInstance.invServerClient configureWithEmpireWebClientHost:[configManager empireManageWebHost]
                                                                    andPort:[configManager empireManageWebPort]];

            [sharedInstance.invServerClient fetchPasswordValidationCriteria:^(id result, INVEmpireMobileError *error) {
                if (error) {
                    INVLogError(@"%@", error);
                    return;
                }

                configManager.passportPasswordVerificationRegex = result[@"regex"];
                configManager.passportPasswordVerificationText = result[@"description"];
            }];
        }
    });

    return sharedInstance;
}

- (NSError *)saveCredentialsInKCForLoggedInUser:(NSString *)email withPassword:(NSString *)password
{
    NSError *error;
    _credentials = @{INV_CredentialKeyEmail : email, INV_CredentialKeyPassword : password};
    [FDKeychain saveItem:_credentials
                  forKey:INV_CredentialsKeychainKey
              forService:[self serviceIdentifierForKCStorage]
                   error:&error];
    if (error) {
        // silently ignoring error
        INVLogError(@"%@", error);
    }
    self.rememberMeOptionSelected = YES;
    return error;
}

- (NSError *)deleteCurrentlySavedCredentialsFromKC
{
    NSError *error;
    [FDKeychain deleteItemForKey:INV_CredentialsKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
    return error;
}

- (NSError *)saveDefaultAccountInKCForLoggedInUser:(NSNumber *)accountId
{
    NSError *error;
    _defaultAccountId = accountId;
    [FDKeychain saveItem:_defaultAccountId
                  forKey:INV_DefaultAccountKeychainKey
              forService:[self serviceIdentifierForKCStorage]
                   error:&error];
    if (error) {
        // silently ignoring error
        INVLogError(@"%@", error);
    }
    return error;
}

- (NSError *)deleteCurrentlySavedDefaultAccountFromKC
{
    NSError *error;
    [FDKeychain deleteItemForKey:INV_DefaultAccountKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
    return error;
}

#pragma mark - public accessors
- (NSDictionary *)credentials
{
    NSError *error;

    _credentials =
        [FDKeychain itemForKey:INV_CredentialsKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
  
    return _credentials;
}

- (NSNumber *)defaultAccountId
{
    NSError *error;

    _defaultAccountId =
        [FDKeychain itemForKey:INV_DefaultAccountKeychainKey forService:[self serviceIdentifierForKCStorage] error:&error];
    return _defaultAccountId;
}

- (NSString *)serviceIdentifierForKCStorage
{
    return [NSBundle bundleForClass:[self class]].bundleIdentifier;
}

- (void)setLoggedInUser:(NSString *)loggedInUser
{
    INVLogDebug(@"Setting logged in user to: %@", loggedInUser);

    _loggedInUser = loggedInUser;
}

- (void)performLogout
{
    [self.invServerClient logOffSignedInUserWithCompletionBlock:^(INVEmpireMobileError *error) {
        self.loggedInAccount = nil;
        self.loggedInUser = nil;
        self.rememberMeOptionSelected = NO;

        [self deleteCurrentlySavedCredentialsFromKC];
        [self deleteCurrentlySavedDefaultAccountFromKC];
        [[NSNotificationCenter defaultCenter] postNotificationName:INV_NotificationUserLogOutSuccess object:nil];
    }];
}

#pragma mark - Tracking Edited Objects
- (BOOL)isRecentlyEditedAccount:(NSNumber *)accountId
{
    return [self.editedAccounts containsObject:accountId];
}
- (void)addToRecentlyEditedAccountList:(NSNumber *)accountId
{
    [self.editedAccounts addObject:accountId];
}
- (void)removeFromRecentlyEditedAccountList:(NSNumber *)accountId
{
    [self.editedAccounts removeObject:accountId];
}

- (BOOL)isRecentlyEditedProject:(NSNumber *)projectId
{
    return [self.editedProjects containsObject:projectId];
}
- (void)addToRecentlyEditedProjectList:(NSNumber *)projectId
{
    [self.editedProjects addObject:projectId];
}
- (void)removeFromRecentlyEditedProjectList:(NSNumber *)projectId
{
    [self.editedProjects removeObject:projectId];
}

- (BOOL)isRecentlyEditedUser:(NSNumber *)userId
{
    return [self.editedUsers containsObject:userId];
}

- (void)addToRecentlyEditedUsersList:(NSNumber *)userId
{
    [self.editedUsers addObject:userId];
}

- (void)removeFromRecentlyEditedUserList:(NSNumber *)userId
{
    [self.editedUsers removeObject:userId];
}

#pragma mark - private accessors
- (NSMutableSet *)editedAccounts
{
    if (!_editedAccounts) {
        _editedAccounts = [[NSMutableSet alloc] initWithCapacity:0];
    }
    return _editedAccounts;
}

- (NSMutableSet *)editedProjects
{
    if (!_editedProjects) {
        _editedProjects = [[NSMutableSet alloc] initWithCapacity:0];
    }
    return _editedProjects;
}

- (NSMutableSet *)editedUsers
{
    if (!_editedUsers) {
        _editedProjects = [[NSMutableSet alloc] initWithCapacity:0];
    }
    return _editedProjects;
}

@end
