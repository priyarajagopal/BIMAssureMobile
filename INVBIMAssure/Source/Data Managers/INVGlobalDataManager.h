//
//  INVGlobalDataManager.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EmpireMobileManager/EmpireMObileManager.h>

/**
 Notifications
 */
extern NSString *const INV_NotificationUserLogOutSuccess;
extern NSString *const INV_NotificationAccountSwitchSuccess;
extern NSString *const INV_NotificationAccountLogOutSuccess;

/**
 Key consts corresponding to credentials Dictionary
 */

typedef NSString *INV_BA_KEY;
extern const NSString *INV_CredentialKeyEmail;
extern const NSString *INV_CredentialKeyPassword;

@interface INVGlobalDataManager : NSObject
@property (nonatomic, readonly) INVEmpireMobileClient *invServerClient;
@property (nonatomic, readonly) NSDictionary *credentials;
@property (nonatomic, readonly) NSNumber *defaultAccountId;
@property (nonatomic, readonly) BOOL rememberMeOptionSelected;
@property (nonatomic, copy) NSString *loggedInUser;
@property (nonatomic, strong) NSNumber *loggedInAccount;
@property (nonatomic, copy) NSString *invitationCodeToAutoAccept;


+ (INVGlobalDataManager *)sharedInstance;

- (NSError *)saveCredentialsInKCForLoggedInUser:(NSString *)email withPassword:(NSString *)password;
- (NSError *)deleteCurrentlySavedCredentialsFromKC;

- (NSError *)saveDefaultAccountInKCForLoggedInUser:(NSNumber *)accountId;
- (NSError *)deleteCurrentlySavedDefaultAccountFromKC;

-(BOOL)isRecentlyEditedAccount:(NSNumber*)accountId;
-(void)addToRecentlyEditedAccountList:(NSNumber*)accountId;
-(void)removeFromRecentlyEditedAccountList:(NSNumber*)accountId;

-(BOOL)isRecentlyEditedProject:(NSNumber*)projectId;
-(void)addToRecentlyEditedProjectList:(NSNumber*)projectId;
-(void)removeFromRecentlyEditedProjectList:(NSNumber*)projectId;

-(BOOL)isRecentlyEditedUser:(NSNumber*)userId;
-(void)addToRecentlyEditedUsersList:(NSNumber*)userId;
-(void)removeFromRecentlyEditedUserList:(NSNumber*)userId;


- (void)performLogout;

@end
