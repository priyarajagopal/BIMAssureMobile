//
//  EmpireMobileClient.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 9/25/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INVEmpireMobileError.h"
#import "INVAccountManager.h"
#import "INVProjectManager.h"
#import "INVRulesManager.h"
#import "INVAnalysesManager.h"
#import "INVRuleExecutionManager.h"
#import "INVRuleInstanceExecution.h"
#import "INVAnalysisRunResult.h"
#import "INVAnalysisRun.h"
#import "INVGenericResponse.h"
#import "INVRuleIssue.h"
#import "INVBAUnit.h"

/**
 Completion Handler that returns the status of the request. In case of no error, the appropriate Data Manager
 (INVAccountManager, INVProjectManager...) can be  queried for the cached results.
 The results of the corresponding requests are not cached.
 */
typedef void (^CompletionHandler)(INVEmpireMobileError *error);

/**
 Completion Handler that returns the status of the request as well the data (if any). The results of the corresponding requests
 are not cached.
 */
typedef void (^CompletionHandlerWithData)(id result, INVEmpireMobileError *error);

@interface INVEmpireMobileClient : NSObject
/**
 The XOS Passport server address
 */
@property (nonatomic, readonly, copy) NSString *passportServer;

/**
 The Empire Manage Server
 */
@property (nonatomic, readonly, copy) NSString *empireManageServer;

/**
 Account Manager resposible for managing responses to account related requests
 */
@property (nonatomic, readonly) INVAccountManager *accountManager;

/**
 Project Manager resposible for managing responses to project related requests
 */
@property (nonatomic, readonly) INVProjectManager *projectManager;

/**
 Rules Manager resposible for managing responses to rules related requests
 */
@property (nonatomic, readonly) INVRulesManager *rulesManager;

/**
 Analyses Manager resposible for managing responses to analyses related requests
 */
@property (nonatomic, readonly) INVAnalysesManager *analysesManager;

/**
 Rule execution Manager resposible for managing responses to rule execution related requests
 */
@property (nonatomic, readonly) INVRuleExecutionManager *ruleExecutionManager;

#pragma mark - Creation
/**
 Creates a singleton instance of EmporeMobileClient and initializes it with the XOS Passport server

 @param passportServer The address of the passport server (eg.127.0.0.1, localhost, www.server.com)

 @param port The port of passport server. This is optional and defaults to 8080

 @return The singleton instance
 */
+ (INVEmpireMobileClient *)sharedInstanceWithXOSPassportServer:(NSString *)passportServer andPort:(NSString *)port;

/**
 Creates a singleton instance of EmporeMobileClient and initializes it with the XOS Passport server

 NOTE: This is used exclusively in test mode so cached data is all in-memory

 @param passportServer The address of the passport server (eg.127.0.0.1, localhost, www.server.com)

 @param port The port of passport server. This is optional and defaults to 8080

 @return The singleton instance
 */
+ (INVEmpireMobileClient *)sharedTestInstanceWithXOSPassportServer:(NSString *)passportServer andPort:(NSString *)port;

/**
 Configures EmpireMobileClient with server address and port

 @param server The address of the Empire Manage server (eg.127.0.0.1, localhost, www.server.com)

 @param port The port of Empire Manage server. This is optional and defaults to 8080.

 */
- (void)configureWithEmpireManageServer:(NSString *)server andPort:(NSString *)port;

#pragma mark - User/Account Management
/**
 Asynchornously ,get password validation regex from server

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, the data
 parameter contains the JSON response of form :
 { "regex": "^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$", "description": "At least one alpha and one numeric and at least 6 characters
 long" }

 @see accountManager


 */
- (void)fetchPasswordValidationCriteria:(CompletionHandlerWithData)handler;

/**
 Asynchronously, reset the password for the user with the specified email.

 @param emailAddress The email address of the user to reset.
 */
- (void)resetPasswordForUserWithEmail:(NSString *)emailAddress withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,update the password for user with current password

 @param emailAddress The email address of the user whose password is to be changed

 @param currentPassword The current password of user

 @param newPassword The new password for user



 */
- (void)updatePasswordForUserWithEmail:(NSString *)emailAddress
                    andCurrentPassword:(NSString *)currentPassword
                       withNewPassword:(NSString *)newPassword
                   withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,update the password for currently signed in user with reset Code

 @param emailAddress The email address of the user whose password is to be changed

 @param resetCode  The reset code that should have been delivered to user by email when he made a resetPassword request

 @param newPassword The new password for user



 */
- (void)updatePasswordForUserWithEmail:(NSString *)emailAddress
                          andResetCode:(NSString *)resetCode
                       withNewPassword:(NSString *)newPassword
                   withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,sign into the XOS Passport service with given email address and password. The user should be registered through
 the Empire Web website.

 @param userName The email address of user

 @param password The password of user

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 accountManager can be used to retrieve the token of the signed in user.

 @see accountManager


 */
- (void)signInWithUserName:(NSString *)userName andPassword:(NSString *)password withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get list of all accounts associated with signed in user.

 @param userName The email address of user

 @param password The password of user

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then
 accountManager can be used to retrieve accounts

 @see -signInWithUserName:andPassword:withCompletionBlock:

 @see accountManager

 */
- (void)getAllAccountsForSignedInUserWithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,sign into specific Empire Manage account via the  XOS Passport service.The user should have signed in via
 signInWithUserName:andPassword:withCompletionBlock

 @param accountId The account Id

 @param handler The completion handler that returns error object if there was any error, accountManager can be used to retrieve
 the signed in user profile info

 @see accountManager

 @see -signInWithUserName:andPassword:withCompletionBlock:

 */
- (void)signIntoAccount:(NSNumber *)accountId withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get profile of signed in user

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then  the
 INVSignedInUser object is returned


 @see -signInWithUserName:andPassword:withCompletionBlock:

 @see accountManager


 */
- (void)getSignedInUserProfileWithCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously ,get profile of specified user

 @param userId The ID of user

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then  the
 INVUser object is returned


 @see -signInWithUserName:andPassword:withCompletionBlock:

 @see accountManager


 */
- (void)getUserProfileInSignedInAccountWithId:(NSNumber *)userId withCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously ,get profile of signed in user


 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then  the
 INVSignedUser object is returned


 @see -signInWithUserName:andPassword:withCompletionBlock:

 @see accountManager


 */
- (void)getUserProfileInSignedUserWithCompletionBlock:(void (^)(INVSignedInUser *user, INVEmpireMobileError *error))handler;

/**
 Asynchornously ,update profile of specified user.User should have signed in with
 -signInWithUserName:andPassword:withCompletionBlock: . The values provided will override
 the existing values so it is important to provide values even for those parameters that are not changed

 NOTE : This API is not fully functional on server side. Should be available shortly

 @param userId The ID of user whose profile is to be updated

 @param firstName FirstName of user to be added

 @param lastName lastName of user to be added

 @param userAddress optional address of user to be added

 @param userPhoneNumber optional phone number of user to be added

 @param userCompanyName optional company name of user to be added

 @param title optional title of user to be added

 @param userEmail email address of user


 @param allowNotifications optional user preference if notifications is to be allowed. It is false be debault

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then  the
 INVUser object is returned

 @see -signInWithUserName:andPassword:withCompletionBlock:

 @see accountManager


 */
- (void)updateUserProfileInSignedInAccountWithId:(NSNumber *)userId
                                   withFirstName:(NSString *)firstName
                                        lastName:(NSString *)lastName
                                     userAddress:(NSString *)userAddress
                                 userPhoneNumber:(NSString *)userPhoneNumber
                                 userCompanyName:(NSString *)userCompanyname
                                           title:(NSString *)title
                                           email:(NSString *)userEmail
                              allowNotifications:(BOOL)allowNotifications
                             withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,update profile of current signed in user.User should have signed in with
 -signInWithUserName:andPassword:withCompletionBlock: . The values provided will override
 the existing values so it is important to provide values even for those parameters that are not changed

 NOTE : This API is not fully functional on server side. Should be available shortly

 @param userId The ID of user whose profile is to be updated

 @param firstName FirstName of user to be added

 @param lastName lastName of user to be added

 @param userAddress optional address of user to be added

 @param userPhoneNumber optional phone number of user to be added

 @param userCompanyName optional company name of user to be added

 @param title optional title of user to be added

 @param userEmail email address of user


 @param allowNotifications optional user preference if notifications is to be allowed. It is false be debault

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then  the
 INVSignedInUser object is returned

 @see -signInWithUserName:andPassword:withCompletionBlock:

 @see accountManager


 */
- (void)updateUserProfileOfUserWithId:(NSNumber *)userId
                        withFirstName:(NSString *)firstName
                             lastName:(NSString *)lastName
                          userAddress:(NSString *)userAddress
                      userPhoneNumber:(NSString *)userPhoneNumber
                      userCompanyName:(NSString *)userCompanyname
                                title:(NSString *)title
                                email:(NSString *)userEmail
                   allowNotifications:(BOOL)allowNotifications
                  withCompletionBlock:(void (^)(INVSignedInUser *user, INVEmpireMobileError *error))handler;

/**
 Asynchornously ,get list of members belonging to currentrly signed in account. If the request is made on behalf of admin user,
 then the list of accounts that a user is a member of is
 also returned. The user must have succesfully used in via signIntoAccount:withCompletionBlock


 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 accountManager can be used to retrieve the account membership info

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager


 */
- (void)getMembershipForSignedInAccountWithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously , invite list of users to currently signed in account.  The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock:

 @param emails List of one or more email addresses of users to invite

 @param role The role to be associated with the invited members of type _INV_MEMBERSHIP_TYPE

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

*/
- (void)inviteUsersToSignedInAccount:(NSArray *)emails
                            withRole:(INV_MEMBERSHIP_TYPE)role
                 withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously, fetch list of invites for user for signed in account.  The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock: to view invites for the account. If success, the list of invites
 can be retrieved using the accountManager

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager

 */
- (void)getPendingInvitationsSignedInAccountWithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously, fetch list of invites for user.  The user must have succesfully into the account via
 signInWithUserName:andPassword:withCompletionBlock to view invites for the user. If success, the list of invites
 can be retrieved using the accountManager

 @param handler The completion handler that returns error object if there was any error.

 @see -signInWithUserName:andPassword:withCompletionBlock

 @see accountManager

 */
- (void)getPendingInvitationsForSignedInUserWithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously, accept invite for user.  The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock: to view invites for the account. The list of pending invitations can be retrieved using
 getPendingInvitationsForSignedInUserWithCompletionBlock: call.

 @param invitationCode The invitation code

 @param userEmail The email address of the user accepting the invitation

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager

 */
- (void)acceptInvite:(NSString *)invitationCode forUser:(NSString *)userEmail withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously, cancel  a pending invite for user.  The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock: to view invites for the account. The list of pending invitations can be retrieved using
 getPendingInvitationsForSignedInUserWithCompletionBlock: call.

 @param invitationId The invitation Id to cancel

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager

 */
- (void)cancelInviteWithInvitationId:(NSNumber *)invitationId withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously, remove user with specified userId from currently signed in account. Only admins are allowed to exercise this
 call.

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager

 */
- (void)removeUserFromSignedInAccountWithUserId:(NSNumber *)userId withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously , sign up for a user account with the XOS Passport service

 @param firstName FirstName of user to be added

 @param lastName lastName of user to be added

 @param userAddress optional address of user to be added

 @param userPhoneNumber optional phone number of user to be added

 @param userCompanyName optional company name of user to be added

 @param title optional title of user to be added

 @param userEmail email address of user

 @paaram password User password

 @param allowNotifications optional user preference if notifications is to be allowed. It is false be debault


 @param accountName Name of account to be created

 @param accountDescription An optional description of account

 @param type Subscription type Will always be mapped to 1 for now

 @param companyName company name

 @param companyAddress Optional company address

 @param contactName  optional name of contact person for company

 @param contactPhone  optional Phone # of contact person for company

 @param numEmployees  optional number of employees

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 accountManager can be used to retrieve the details of account. Instance of INVUser is created

 @see accountManager


 */

- (void)signUpUserWithFirstName:(NSString *)firstName
                       lastName:(NSString *)lastName
                    userAddress:(NSString *)userAddress
                userPhoneNumber:(NSString *)userPhoneNumber
                userCompanyName:(NSString *)userCompanyName
                          title:(NSString *)title
                          email:(NSString *)userEmail
                       password:(NSString *)password
             allowNotifications:(BOOL)allowNotifications
                    accountName:(NSString *)accountName
             accountDescription:(NSString *)accountDescription
               subscriptionType:(NSNumber *)type
                    companyName:(NSString *)companyName
                 companyAddress:(NSString *)companyAddress
                    contactName:(NSString *)contactName
                   contactPhone:(NSString *)contactPhone
                numberEmployees:(NSNumber *)numEmployees
            withCompletionBlock:(CompletionHandlerWithData)handler;
/**
 Asynchornously , sign up a user with the XOS Passport service

 @param firstName FirstName of user to be added

 @param lastName lastName of user to be added

 @param userAddress optional address of user to be added

 @param userPhoneNumber optional phone number of user to be added

 @param userCompanyName optional company name of user to be added

 @param title optional title of user to be added

 @param userEmail email address of user

@paaram password User password

 @param allowNotifications optional user preference if notifications is to be allowed. It is false be debault


 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 accountManager can be used to retrieve the details of account. Instance of INVUser is returned

 @see accountManager


 */
- (void)signUpUserWithFirstName:(NSString *)firstName
                       lastName:(NSString *)lastName
                    userAddress:(NSString *)userAddress
                userPhoneNumber:(NSString *)userPhoneNumber
                userCompanyName:(NSString *)userCompanyname
                          title:(NSString *)title
                          email:(NSString *)userEmail
                       password:(NSString *)password
             allowNotifications:(BOOL)allowNotifications
            withCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously , create an account for currently signed in user with the XOS Passport service

 @param accountName Name of account to be created

 @param accountDescription An optional description of account

 @param type Subscription type Will always be mapped to 1 for now

 @param companyName company name

 @param companyAddress Optional company address

 @param contactName  optional name of contact person for company

 @param contactPhone  optional Phone # of contact person for company

 @param numEmployees  optional number of employees


 @param userEmail The email address of signed in user. ***** THE SERVER API SHOULD BE UPDATED TO NOT REQUIRE THIS FIELD ******

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 accountManager can be used to retrieve the details of account. Instance of INVAccount is returned

 @see accountManager


 */
- (void)createAccountForSignedInUserWithAccountName:(NSString *)accountName
                                 accountDescription:(NSString *)accountDescription
                                   subscriptionType:(NSNumber *)type
                                        companyName:(NSString *)companyName
                                     companyAddress:(NSString *)companyAddress
                                        contactName:(NSString *)contactName
                                       contactPhone:(NSString *)contactPhone
                                    numberEmployees:(NSNumber *)numEmployees
                                       forUserEmail:(NSString *)userEmail
                                withCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously , disable an account for currently signed in account. Once disabled, the account
 can only be reenabled by out-of-band means(not via an API). Accounts that are disabled are not deleted.


 @param handler The completion handler that returns error object if there was any error.

 @see accountManager

 @see -signIntoAccount:withCompletionBlock:

 */
- (void)disableAccountForSignedInAccountWithCompletionBlock:(CompletionHandler)handler;

/**
Asynchornously , update details of signed in account with the XOS Passport service. If values are not changed, then the existing
values must be provided. Providing null will override
 the existing values

 NOTE: This API has a bug on server side and is not functional. Use updateSignedInAccountDetailsWithAccountId: ...

 @param accountDescription An optional description of account

 @param type Subscription type Will always be mapped to 1 for now

 @param companyName company name

 @param companyAddress Optional company address

 @param contactName  optional name of contact person for company

 @param contactPhone  optional Phone # of contact person for company

 @param numEmployees  optional number of employees

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 accountManager can be used to retrieve the details of account

 @see accountManager


 */
- (void)updateSignedInAccountDetailsWithName:(NSString *)accountName
                          accountDescription:(NSString *)accountDescription
                            subscriptionType:(NSNumber *)type
                                 companyName:(NSString *)companyName
                              companyAddress:(NSString *)companyAddress
                                 contactName:(NSString *)contactName
                                contactPhone:(NSString *)contactPhone
                             numberEmployees:(NSNumber *)numEmployees
                                forUserEmail:(NSString *)userEmail
                         withCompletionBlock:(CompletionHandler)handler;

/*
Asynchornously , update details of the specified account with the XOS Passport service. If values are not changed, then the
existing
values must be provided. Providing null will override
the existing values

 NOTE: Currently only the signed in account can be edited! This is a bug on server side that is tracked

 @param accountId The Id of the account

 @param accountName updated name of account

 @param accountDescription An optional description of account

 @param type Subscription type Will always be mapped to 1 for now

 @param companyName company name

 @param companyAddress Optional company address

 @param contactName  optional name of contact person for company

 @param contactPhone  optional Phone # of contact person for company

 @param numEmployees  optional number of employees

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
accountManager can be used to retrieve the details of account

@see accountManager


*/
- (void)updateAccountDetailsWithAccountId:(NSNumber *)accountId
                                     name:(NSString *)accountName
                       accountDescription:(NSString *)accountDescription
                         subscriptionType:(NSNumber *)type
                              companyName:(NSString *)companyName
                           companyAddress:(NSString *)companyAddress
                              contactName:(NSString *)contactName
                             contactPhone:(NSString *)contactPhone
                          numberEmployees:(NSNumber *)numEmployees
                      withCompletionBlock:(CompletionHandler)handler;

#pragma mark - project management

/**
 Asynchornously ,create project with specified name. Only an admin is capable of exercising this call.

 @param projectName name of project

 @param overview Description of project (currently unused in backend)

 @param handler The completion handler that returns error object if there was any error. The INVProject object is returned

 @see -signIntoAccount:withCompletionBlock:

 */
- (void)createProjectWithName:(NSString *)projectName
                           andDescription:(NSString *)overview
    ForSignedInAccountWithCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously ,edit project with specified Id. Only an admin is capable of exercising this call. This API is not supported in
 the backend

 @param projectId The Id of project to be updated

 @param projectName updated name of project

 @param overview updated Description of project (currently unused in backend)

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 */
- (void)updateProjectWithId:(NSNumber *)projectId
                                 withName:(NSString *)projectName
                           andDescription:(NSString *)overview
    ForSignedInAccountWithCompletionBlock:(CompletionHandler)handler;

#pragma mark - Model Related

/**
 Asynchornously, fetch the JSON corresponding to the model from the server. The model data is NOT locally cached

 @param handler The completion handler that returns error object if there was any error. If error is nil, it returns the JSON
 model data

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager

 */
- (void)fetchModelViewForId:(NSNumber *)modelId withCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Convenience method that retuns a NSURLRequest to fetch the JSON model data. This provides the flexibility for clients to fetch
 and process the data
 as they choose to. If there is an error, a nil value is returned

 DEPRECATED - Use requestToFetchGeomInfoForPkgVersion: and

 @param pkgVersion the Id of the model whose JSON data is to fetched

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager

 */
- (NSURLRequest *)requestToFetchModelViewForId:(NSNumber *)pkgVersion;

/**
 Convenience method that retuns a NSURLRequest to fetch the germetry data corresponding to the pkg version. This returns a list
 of geometry files. Use requestToFetchModelViewForPkgVersion:forFile:
 to fetch the geometry info for each of the file listed in requestToFetchGeomInfoForPkgVersion:

 This provides the flexibility for clients to fetch
 and process the data
 as they choose to. If there is an error, a nil value is returned

 @param pkgVersion the Id of the model whose JSON data is to fetched

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager

 */
- (NSURLRequest *)requestToFetchGeomInfoForPkgVersion:(NSNumber *)pkgVersion;

/**
 Convenience method that retuns a NSURLRequest to fetch the JSON model data. This provides the flexibility for clients to fetch
 and process the data
 as they choose to. If there is an error, a nil value is returned

 @param pkgVersion the Id of the model whose JSON data is to fetched

 @param file The file is the .json file that is retrieved from requestToFetchGeomInfoForPkgVersion:

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager

 */
- (NSURLRequest *)requestToFetchModelViewForPkgVersion:(NSNumber *)pkgVersion forFile:(NSString *)file;

/**
 Convenience method that retuns a NSURLRequest to fetch the JSON model data. This provides the flexibility for clients to fetch
 and process the data
 as they choose to. If there is an error, a nil value is returned

 @param modelId the Id of the model whose JSON data is to fetched

 @see -signIntoAccount:withCompletionBlock:

 @see accountManager

 */
- (NSURLRequest *)requestToFetchModelViewForId:(NSNumber *)modelId;

#pragma mark - Projects Related

/**
 Asynchornously ,get list of all projects for signed in account. Users should have signed in via the
 signIntoAccount:withCompletionBlock: method.

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then
 projectManager can be used to retrieve projects

 @see -signIntoAccount:withCompletionBlock:

 @see projectManager

 */
- (void)getAllProjectsForSignedInAccountWithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get count of all projects for signed in account. Users should have signed in via the
 signIntoAccount:withCompletionBlock: method.

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then
 projectManager can be used to retrieve projects

 @see -signIntoAccount:withCompletionBlock:

 @see projectManager

 */
- (void)getProjectCountForSignedInAccountWithCompletionBlock:(void (^)(INVGenericResponse *response,
                                                                 INVEmpireMobileError *error))handler;

/**
 Asynchornously ,get list of all projects for signed in account from specified offset and with specified page count. Users
 should have signed in via the signIntoAccount:withCompletionBlock: method.

 @param offset The starting offset from which data is to be fetched

 @param pageSize The number of elements to be fetched

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then
 projectManager can be used to retrieve projects

 @see -signIntoAccount:withCompletionBlock:

 @see projectManager

 */
- (void)getAllProjectsForSignedInAccountWithOffset:(NSNumber *)offset
                                          pageSize:(NSNumber *)pageSize
                               WithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get count of number of pkg master associated with a project. Users must have signed into an account in order to
 be able to fetch project files.

 @param projectId The project Id

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 response handler includes an NSNumber corresponding to the pkg master count

 @see -signIntoAccount:withCompletionBlock:

 @see projectManager

 */
- (void)getPkgMasterCountForProject:(NSNumber *)projectId
                WithCompletionBlock:(void (^)(INVGenericResponse *response, INVEmpireMobileError *error))handler;

/**
 Asynchornously ,get list of all files associated with a project. Users must have signed into an account in order to be able to
 fetch project files.

 @param projectId The project Id

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 projectManager can be used to retrieve projects

 @see -signIntoAccount:withCompletionBlock:

 @see projectManager

 */
- (void)getAllPkgMastersForProject:(NSNumber *)projectId WithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get list of all files associated with a project. Users must have signed into an account in order to be able to
 fetch project files.

 @param projectId The project Id

 @param offset The starting offset from which data is to be fetched

 @param pageSize The number of elements to be fetched


 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 projectManager can be used to retrieve projects

 @see -signIntoAccount:withCompletionBlock:

 @see projectManager

 */
- (void)getAllPkgMastersForProject:(NSNumber *)projectId
                        WithOffset:(NSNumber *)offset
                          pageSize:(NSNumber *)pageSize
               WithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get list of all rulesets associated with a project. Users must have signed into an account in order to be able
 to fetch rule sets.

 @param projectId The id of the project

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve rulesets

 @see -signIntoAccount:withCompletionBlock:

 @see rulesManager

 */
- (void)getAllRuleSetsForProject:(NSNumber *)projectId WithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get ruleset associated with a rule set Id. Users must have signed into an account in order to be able to fetch
 rule sets.

 @param ruleSetId The id of the rulesetId

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve rulesets

 @see -signIntoAccount:withCompletionBlock:

 @see rulesManager

 */
- (void)getRuleSetForRuleSetId:(NSNumber *)ruleSetId WithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,delete a project for signed in account. Users should have signed in via the
 signIntoAccount:withCompletionBlock: method.

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:


 */
- (void)deleteProjectWithId:(NSNumber *)projectId ForSignedInAccountWithCompletionBlock:(CompletionHandler)handler;

#pragma mark - Thumbnails related
/**
 Asynchornously ,get thumbnail image for specified package versionId. Users should have signed in via the
 signIntoAccount:withCompletionBlock: method.

 @param pkgVersionId Package Version Id

 @param handler The completion handler that returns error object if there was any error or JPeg representation of image

 @see -signIntoAccount:withCompletionBlock:


 */
- (void)getThumbnailImageForPkgVersion:(NSNumber *)pkgVersionId
    ForSignedInAccountWithCompletionBlock:(CompletionHandlerWithData)handler;

/**
 return request to fetch thumbnail image for specified pkgVersion. User should have signed in with
 -signInUser:withCompletionBlock:

 @param pkgVersionId Id of pkgVersionId

 @param handler The NSURLRequest

 @see -signIntoUser:withCompletionBlock:

 */
- (NSURLRequest *)requestToGetThumbnailImageForPkgVersionId:(NSNumber *)pkgVersionId;

/**
 Asynchornously ,add thumbnail image for signed in account. Users should have signed in with
 signIntoAccount:withCompletionBlock:

 @param thumbnail The file URL of thumbnail image

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:


 */
- (void)addThumbnailImageForSignedInAccountWithThumbnail:(NSURL *)thumbnail withCompletionHandler:(CompletionHandler)handler;

/**
 Asynchornously,fet thumbnail image for account

 @param accountId Id of account for which image should be fetched

 @param handler The completion handler that returns error object if there was any error. IF not an error, PNG representation of
 image data in NSData format
 corresponding to the image is returned


 @see -signIntoAccount:withCompletionBlock:

 */
- (void)getThumbnailImageForAccount:(NSNumber *)accountId withCompletionHandler:(CompletionHandlerWithData)handler;

/**
 return request to fetch thumbnail image for specified account. User should have signed in with -signInUser:withCompletionBlock:

 @param accountId Id of account

 @param handler The NSURLRequest

 @see -signIntoUser:withCompletionBlock:

 */
- (NSURLRequest *)requestToGetThumbnailImageForAccount:(NSNumber *)accountId;

/**
 Asynchornously,add thumbnail image for project

 @param projectId Id of project for which image should be added

 @param thumbnail The file URL of thumbnail image

 @param handler The completion handler that returns error object if there was any error.

 @see -signInUser:withCompletionBlock:


 */
- (void)addThumbnailImageForProject:(NSNumber *)projectId
                          thumbnail:(NSURL *)thumbnail
              withCompletionHandler:(CompletionHandler)handler;

/**
 Asynchornously ,get thumbnail image for project

 @param projectId Id of project for which image should be fetched


 @param handler The completion handler that returns error object if there was any error. IF not an error, PNG representation of
 image data in NSData format
 corresponding to the image is returned

 @see -signIntoAccount:withCompletionBlock:

 */
- (void)getThumbnailImageForProject:(NSNumber *)projectId withCompletionHandler:(CompletionHandlerWithData)handler;

/**
 return request to fetch thumbnail image for specified project. User should have signed in with -signInUser:withCompletionBlock:

 @param projectId Id of project

 @param handler The NSURLRequest

 @see -signIntoUser:withCompletionBlock:

 */
- (NSURLRequest *)requestToGetThumbnailImageForProject:(NSNumber *)projectId;

/**
 Asynchornously,add thumbnail image for signed in user. User should have been signed in with -signInUser:withCompletionBlock:

 ***NOTE*** Due to a server side issue , the user shouolkd be signed into an account in order to upload the image. This should
 be fixed in next version

 @param thumbnail The file URL of thumbnail image

 @param handler The completion handler that returns error object if there was any error.

 @see -signInUser:withCompletionBlock:


 */
- (void)addThumbnailImageForSignedInUserWithThumbnail:(NSURL *)thumbnail withCompletionHandler:(CompletionHandler)handler;

/**
 Asynchornously ,get thumbnail image for specified user . User should have signed in with -signInUser:withCompletionBlock:

 @param userId Id of user

 @param handler The completion handler that returns error object if there was any error. IF not an error, PNG representation of
 image data in NSData format
 corresponding to the image is returned

 @see -signIntoUser:withCompletionBlock:

 */
- (void)getThumbnailImageForUser:(NSNumber *)userId withCompletionHandler:(CompletionHandlerWithData)handler;

/**
 return request to fetch thumbnail image for specified user . User should have signed in with -signInUser:withCompletionBlock:

 @param userId Id of user

 @param handler The NSURLRequest

 @see -signIntoUser:withCompletionBlock:

 */
- (NSURLRequest *)requestToGetThumbnailImageForUser:(NSNumber *)userId;

#pragma mark - Rule Sets Membership Related

/**
 Asynchornously ,get list of all package masters associated with a ruleset. Users must have signed into an account in order to
 be able to fetch file masters.

 @param ruleSetId The ruleset for which the file masters need to be fetched

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve files for the project

 @see -signIntoAccount:withCompletionBlock:

 @see rulesManager

 */
- (void)getAllPkgMastersForRuleSet:(NSNumber *)ruleSetId WithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously , add the list of package masters to a ruleset. The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock:

 @param ruleSetId  The rule set Id

 @param pkgMasters The list of file masters to be associated with the rule set

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 */
- (void)addToRuleSet:(NSNumber *)ruleSetId pkgMasters:(NSArray *)pkgMasters withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously , remove pkgMaster from rule set. The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock:

 @param ruleSetId  The rule set Id

 @param pkgMasterId The Id of Pkg master to be removed

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 */
- (void)removeFromRuleSet:(NSNumber *)ruleSetId
                pkgMaster:(NSNumber *)pkgMasterId
      withCompletionBlock:(CompletionHandler)handler;

#pragma mark - Package Membership Related

/**
 Asynchornously ,get list of all rulesets associated with a file. Users must have signed into an account in order to be able to
 fetch rule sets.

 @param pkgMasterId The Id of the file master for which rulesets are to be fetched

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve rulesets

 @see -signIntoAccount:withCompletionBlock:

 @see rulesManager

 */
- (void)getAllRuleSetMembersForPkgMaster:(NSNumber *)pkgMasterId WithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously , add the list of rulesets associated with a pkg master  The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock:

 @param pkgMasterId  The Id of Pkg master

 @param rulesetIds The list of ruleset Ids to be associated with the package

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 */
- (void)addToPkgMaster:(NSNumber *)pkgMasterId ruleSets:(NSArray *)rulesetIds withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously , remove the list of package masters to a ruleset. The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock:

 @param pkgMasterId  The Id of Pkg master

 @param ruleSetId  The rule set Id to be removed

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 */
- (void)removeFromPkgMaster:(NSNumber *)pkgMasterId
                    ruleSet:(NSNumber *)ruleSetId
        withCompletionBlock:(CompletionHandler)handler;

#pragma mark - Rule Instances management

/**
 Asynchornously ,create a specified rule instance.

 @param ruleId The Id of the rule definition corresponding to the instance

 @param ruleName The name of the tule

 @param overview The rule description

 @param actualParams A dictionary of key:value pairs representing the actual parameters for the given instance

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve rulesets

 @see -signIntoAccount:withCompletionBlock:


 */
- (void)old_createRuleInstanceForRuleId:(NSNumber *)ruleId
                            inRuleSetId:(NSNumber *)ruleSetId
                           withRuleName:(NSString *)ruleName
                         andDescription:(NSString *)overview
                    andActualParameters:(INVRuleInstanceActualParamDictionary)actualParams
                    WithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,update the specified rule instance.

 @param ruleInstanceId The id of the rule Instance

 @param ruleId The Id of the rule definition corresponding to the instance

 @param ruleName The name of the tule

 @param overview The rule description

 @param actualParams A dictionary of key:value pairs representing the actual parameters for the given instance

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve rulesets

 @see -signIntoAccount:withCompletionBlock:


 */
- (void)old_modifyRuleInstanceForRuleInstanceId:(NSNumber *)ruleInstanceId
                                      forRuleId:(NSNumber *)ruleId
                                    inRuleSetId:(NSNumber *)ruleSetId
                                   withRuleName:(NSString *)ruleName
                                 andDescription:(NSString *)overview
                            andActualParameters:(INVRuleInstanceActualParamDictionary)actualParams
                            WithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,delete the specified rule instance.

 @param ruleInstanceId The id of the rule Instance
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve rulesets

 @see -signIntoAccount:withCompletionBlock:


 */
- (void)old_deleteRuleInstanceForId:(NSNumber *)ruleInstanceId WithCompletionBlock:(CompletionHandler)handler;

#pragma mark - Rules Definition Related
/**
 Asynchornously ,get list of all rules associated with a account. Users must have signed into an account in order to be able to
 fetch rules.

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve rules

 @see -signIntoAccount:withCompletionBlock:

 @see rulesManager

 */
- (void)old_getAllRuleDefinitionsForSignedInAccountWithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get rule definition associated with specific ruleId. Users must have signed into an account in order to be able
 to fetch rules.

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve rules

 @see -signIntoAccount:withCompletionBlock:

 @see rulesManager

 */
- (void)old_getRuleDefinitionForRuleId:(NSNumber *)ruleId WithCompletionBlock:(CompletionHandler)handler;

#pragma mark - Rules Execution Related
/**
 Asynchornously , execute a ruleset against a pkg version . All rule instances within rule set will be executed. The user must
 have succesfully into the account via signIntoAccount:withCompletionBlock:

 @param ruleSetId  The Id of the ruleset

 @param packageVersionId The Id of the file version

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 @see ruleExecutionManager

 */
- (void)old_executeRuleSet:(NSNumber *)ruleSetId
    againstPackageVersionId:(NSNumber *)pkgVersionId
        withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously , execute a specific rule instance against a pkg version.  The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock:

 @param ruleInstanceId  The Id of the rule instance

 @param pkgVersionId The Id of the file version

 @param handler The completion handler that returns error object if there was any error.

 @see -signIntoAccount:withCompletionBlock:

 @see ruleExecutionManager

 */
- (void)old_executeRuleInstance:(NSNumber *)ruleInstanceId
        againstPackageVersionId:(NSNumber *)pkgVersionId
            withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously , fetch  the executions scheduled on a package version . Every execution that is scheduled via
 executeRuleInstance:againstFileVersionId:againstModel:withCompletionBlock
 and executeRuleSet:againstFileVersionId:againstModel:withCompletionBlock  will be associated with a unique GroupTag. The
 execution results are available via INVRulesManager.
 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:


 @param pkgVersionId The Id of the package version

 @param handler The completion handler that returns error object if there was any error.

 @see rulesManager

 @see -executeRuleSet:againstFileVersionId:againstModel:withCompletionBlock:

 @see -executeRuleInstance:againstFileVersionId:againstModel:withCompletionBlock:

 */
- (void)old_fetchRuleExecutionsForPackageVersionId:(NSNumber *)pkgVersionId withCompletionBlock:(CompletionHandler)handler;

#pragma mark - Model/Building Related
/**
 Asynchornously , fetch details of issues for specified Id
 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:

 @param issueId The Id of the issue whose details are to be fetched

 @param handler The completion handler that returns error object if there was any error. If no error, details can be queried via
 the INVRuleExecutionsManager interface

 @see ruleExecutionsManager

 */
- (void)old_fetchIssueDetailsForId:(NSNumber *)issueId withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously , fetch top level categories of building elements for specified package. This API does not currently support
 pagination.

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:

 @param pkgId The Id of the package for which the building elements are to be fetched

 @param fromOffset optional value to specify zero-based-offset from where to fetch the elements. Passing nil defaults to
 0.Offset

 @param size optional value to specify the number of items to be fetched. Passing nil defaults to all.

 @param handler The completion handler that returns error object if there was any error. If no error, JSON response is returned
 in the completion handler


 */
- (void)fetchBuildingElementCategoriesForPackageVersionId:(NSNumber *)pkgId
                                      withCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously , fetch building elements for specified category for specified package. The category display name must be
 retrieved using fetchBuildingElementCategoriesForPackage:withCompletionBlock

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:

 @param categoryName The display name of the category

 @param pkgId The Id of the package for which the building elements are to be fetched

 @param fromOffset optional value to specify zero-based-offset from where to fetch the elements. Passing nil defaults to
 0.Offset

 @param size optional value to specify the number of items to be fetched. Passing nil defaults to all.

 @param handler The completion handler that returns error object if there was any error. If no error, JSON response is returned
 in the completion handler

 @see fetchBuildingElementCategoriesForPackage:withCompletionBlock
 */
- (void)fetchBuildingElementOfSpecifiedCategoryWithDisplayname:(NSString *)categoryName
                                           ForPackageVersionId:(NSNumber *)pkgId
                                                    fromOffset:(NSNumber *)offset
                                                      withSize:(NSNumber *)size
                                           withCompletionBlock:(CompletionHandlerWithData)handler;

/*
 Asynchornously , fetch properties of specific building element for specified package. The build element Id  must be
 retrived using fetchBuildingElementOfSpecifiedCategoryWithDisplayname:ForPackageVersionId:withCompletionBlock

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 @param buildingElementId The Id of the building element whose properties are to be fetched


 @param pkgId The Id of the package for which the building elements are to be fetched

 @param fromOffset optional value to specify zero-based-offset from where to fetch the elements. Passing nil defaults to
 0.Offset

 @param size optional value to specify the number of items to be fetched. Passing nil defaults to all.

 @param handler The completion handler that returns error object if there was any error. If no error, JSON response is returned
 in the completion handler

 @see fetchBuildingElementCategoriesForPackage:withCompletionBlock
 */
- (void)fetchBuildingElementPropertiesOfSpecifiedElement:(NSString *)buildingElementId
                                     ForPackageVersionId:(NSNumber *)pkgId
                                              fromOffset:(NSNumber *)offset
                                                withSize:(NSNumber *)size
                                     withCompletionBlock:(CompletionHandlerWithData)handler;

/*
 Asynchornously , fetch list of normalized BA types. The types will be returned in alphabetical order of name

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
  @param fromOffset optional value to specify zero-based-offset from where to fetch the elements. Passing nil defaults to
 0.Offset

 @param size optional value to specify the number of items to be fetched. Passing nil defaults to all.

 @param handler The completion handler that returns error object if there was any error. If no error, JSON response is returned
 in the completion handler

 */
- (void)fetchBATypesFromOffset:(NSNumber *)offset
                      withSize:(NSNumber *)size
           withCompletionBlock:(CompletionHandlerWithData)handler;

/*
 Asynchornously , fetch list of normalized BA types filtered by specified name and/or code

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:

 @param displayName  the name to be filtered on. Can be nil

 @param code The code to be filtered on. Can ne nil

 @param fromOffset optional value to specify zero-based-offset from where to fetch the elements. Passing nil defaults to
 0.Offset

 @param size optional value to specify the number of items to be fetched. Passing nil defaults to all.

 @param handler The completion handler that returns error object if there was any error. If no error, JSON response is returned
 in the completion handler

 */
- (void)fetchBATypesFilteredByName:(NSString *)displayName
                           andCode:(NSString *)code
                        fromOffset:(NSNumber *)offset
                          withSize:(NSNumber *)size
               withCompletionBlock:(CompletionHandlerWithData)handler;

/*
 Asynchornously , fetch display name of BA type for specific code


 @param code The BA code

 @param handler The completion handler that returns error object if there was any error. If no error, the name is returned
 */
- (void)fetchBATypeDisplayNameForCode:(NSString *)code withCompletionBlock:(CompletionHandlerWithData)handler;

/*
 Asynchornously , fetch list of all units

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:


 @param handler The completion handler that returns error object if there was any error. If no error, an array of INVBAUnit
 fields are returned
 in the completion handler

 */
- (void)fetchSupportedUnitsForSignedInAccountWithCompletionBlock:(void (^)(
                                                                     INVBAUnitArray units, INVEmpireMobileError *error))handler;

#pragma mark Basic Analyses related

/*
 Asynchornously , fadd an analysis to a project.

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:

 @param projectId The Id of the project to which analysis is to be added

 @param name required Name of analysis

 @param description Required description of analysis

 @param handler The completion handler that returns error object if there was any error. If no error, JSON response is returned
 in the completion handler that is of type INVAnalysis

  @see analysesManager
 */
- (void)addAnalysesToProject:(NSNumber *)projectId
                    withName:(NSString *)name
              andDescription:(NSString *)description
         withCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously ,get list of all analyses associated with a project. Users must have signed into an account in order to be able
 to
 fetch analyses

 @param projectId the Id of the project
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 analysesManager can be used to retrieve analyses

 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager

 */
- (void)getAllAnalysesForProject:(NSNumber *)project withCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get analysis for specified Id. the INVAnalysis object is returned

 @param analysisId the Id of the analysis

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
INVAnalysis object is returned

 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager

 */
- (void)getAnalysesForId:(NSNumber *)analysisId withCompletionBlock:(CompletionHandlerWithData)handler;

/*
 Asynchornously , update basic info associated with an analyses .

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:

 @param analysis The Id of the analysis to be updated

 @param name required Name of analysis

 @param description Required description of analysis

 @param handler The completion handler that returns error object if there was any error. If no error, JSON response is returned
 in the completion handler that is of type INVAnalysis

  @see analysesManager
  */
- (void)updateAnalyses:(NSNumber *)analysisId
               withName:(NSString *)name
         andDescription:(NSString *)description
    withCompletionBlock:(CompletionHandlerWithData)handler;

/*
 Asynchornously , delete an analysis.

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:

 @param analysisId The Id of the analysis to be deleted


 @param handler The completion handler that returns error object if there was any error. If no error, nil returned

 @see analysesManager

 */
- (void)deleteAnalyses:(NSNumber *)analysisId withCompletionBlock:(CompletionHandler)handler;

/*
 Asynchornously , fetch analysis for pkg master

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:

 @param pkgMasterId The Id of the pkg master to which analyses is to be fetched


 @param projectId The Id of the project containing the pkg master
 
 @param handler The completion handler that returns error object if there was any error.If error parameter is nil, then
 analysesManager can be used to retrieve analyses

 @see analysesManager
 */
- (void)getAllAnalysisForPkgMaster:(NSNumber *)pkgMasterId inProject:(NSNumber*)projectId withCompletionBlock:(CompletionHandler)handler;

#pragma mark Analyses Pkg Master Membership Related

/**
 Asynchornously ,get list of all package masters associated with a analyses. Users must have signed into an account in order to
 be able to fetch file masters.

 @param analysisId The analysis for which the package masters need to be fetched

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 then membership data is returned.
 The analysesManager can be used to retrieve pkg master list

 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager


 */
- (void)getPkgMembershipForAnalysis:(NSNumber *)analysisId WithCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously , add the list of package masters to a analysis. The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock:

 @param analysisId  The analysis Id

 @param pkgMasters The list of package master ids to be associated with the rule set

 @param handler The completion handler that returns error object if there was any error. If no error, then return analysis
 membership

 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager

 */
- (void)addToAnalysis:(NSNumber *)analysisId
             pkgMasters:(NSArray *)pkgMasters
    withCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously , add the list of analyses to a package master. The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock:

 @param pkgMasterId  The package master Id

 @param analyses The list of analyses to be associated with the pkg master

 @param handler The completion handler that returns error object if there was any error. If no error, then return analysis
 membership

 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager

 */
- (void)addToPkgMaster:(NSNumber *)pkgMasterId
               analyses:(NSArray *)analyses
    withCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously , add the list of rule Ids to analysis The user must have succesfully into the account via
 signIntoAccount:withCompletionBlock:

 @param analysisId  The analysis Id

 @param ruleDefIds The list of rule definition ids to be associated with the rule set

 @param handler The completion handler that returns error object if there was any error. If no error, then return analysis
 membership

 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager

 */
- (void)addToAnalysis:(NSNumber *)analysisId
      ruleDefinitionIds:(NSArray *)ruleDefIds
    withCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously ,get list of all analyses  associated with a pkg master. Users must have signed into an account in order to
 be able to fetch analyses

 @param pkgMasterId The pkgMasterId for which the analyses  need to be fetched

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 then membership data is returned.
 The analysesManager can be used to retrieve pkg master list

 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager


 */
- (void)getAnalysisMembershipForPkgMaster:(NSNumber *)pkgMasterId WithCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously ,remove specified package master members associated with a analyses. Users must have signed into an account in
 order to
 be able to fetch file masters.

 @param analysisMembershipId The analysis membership Id to be removed

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve files for the project

 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager


 */
- (void)removeAnalysisMembership:(NSNumber *)analysisMembershipId WithCompletionBlock:(CompletionHandler)handler;

#pragma mark Rule Definitions Related

/**
 Asynchornously ,get list of all rules associated with a account. Users must have signed into an account in order to be able to
 fetch rules.

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 analysesManager can be used to retrieve rules

 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager

 */
- (void)getAllRuleDefinitionsForSignedInAccountWithCompletionBlock:(CompletionHandler)handler;

/**
 Asynchornously ,get rule definition associated with specific ruleId. Users must have signed into an account in order to be able
 to fetch rules.

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then INVRule
 object is returned in callback


 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager

 */
- (void)getRuleDefinitionForRuleId:(NSNumber *)ruleId WithCompletionBlock:(CompletionHandlerWithData)handler;

#pragma mark Rules (Instances) Related

/**
 Asynchornously ,create a specified rule instance from a rule definition and associate it with an analyses.

 @param ruleId The Id of the rule definition corresponding to the instance

 @param analysisId the Id of the rule analyses that the rule is associated with

 @param ruleName The name of the tule

 @param overview The rule description

 @param actualParams A dictionary of key:value pairs representing the actual parameters for the given instance

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 newly created rule instance is returned

 @see -signIntoAccount:withCompletionBlock:


 */
- (void)createRuleForRuleDefinitionId:(NSNumber *)ruleId
                           inAnalysis:(NSNumber *)analysisId
                         withRuleName:(NSString *)ruleName
                       andDescription:(NSString *)overview
                  andActualParameters:(INVRuleInstanceActualParamDictionary)actualParams
                  WithCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously ,update the specified rule instance associated with an analyses. All values provided will override existing
 values. So must provide existing values if they are to be unchanged.

 @param ruleInstanceId The id of the rule Instance

 @param ruleId The Id of the rule definition corresponding to the instance

 @param analysisId The id of the analysis

 @param ruleName The name of the rule.

 @param overview The rule description

 @param actualParams A dictionary of key:value pairs representing the actual parameters for the given instance

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 updated rule instance is returned

 @see -signIntoAccount:withCompletionBlock:


 */
- (void)modifyRuleInstanceForRuleInstanceId:(NSNumber *)ruleInstanceId
                                  forRuleId:(NSNumber *)ruleId
                                 inAnalysis:(NSNumber *)analysisId
                               withRuleName:(NSString *)ruleName
                             andDescription:(NSString *)overview
                        andActualParameters:(INVRuleInstanceActualParamDictionary)actualParams
                        WithCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously ,delete the specified rule instance.

 @param ruleInstanceId The id of the rule Instance
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then
 rulesManager can be used to retrieve rulesets

 @see -signIntoAccount:withCompletionBlock:


 */
- (void)deleteRuleInstanceForId:(NSNumber *)ruleInstanceId WithCompletionBlock:(CompletionHandler)handler;

#pragma mark Analyses Execution Related
/**
 Asynchornously ,run specified analysis. The analysis run results ARE NOT cached

 @param analysisId The Id of analysis to be executed

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, the status
 of execution can be retrieved getExecutionResultsForAnalysisRun:WithCompletionBlock:. The handler returns the Ids of the
 analyses runs (there would be a separate analysesrun Id for every  rule that is executed)
 @see -signIntoAccount:withCompletionBlock:

 @see analysesManager

 @see getExecutionResultsForAnalysisRun:WithCompletionBlock:


 */
- (void)runAnalysis:(NSNumber *)analysisId WithCompletionBlock:(CompletionHandlerWithData)handler;

#pragma mark Analyses Execution Results Related

/**
 Asynchornously ,get list of analysis tuns that is scheduled using runAnalysis:WithCompletionBlock. The execution results ARE
 NOT cached. The details of result of the run can be fetcged using getExecutionResultsForAnalysisRun:WithCompletionBlock

 @param analysisId The Id of analysis to be executed

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, the status
 of execution is returned in the handler

 @see -signIntoAccount:withCompletionBlock:

 @see -getExecutionResultsForAnalysisRun:WithCompletionBlock

 @see -runAnalysis:WithCompletionBlock:

 @see analysesManager


 */
- (void)getAnalysisRunsForAnalysis:(NSNumber *)analysisId WithCompletionBlock:(CompletionHandlerWithData)handler;

/**
 Asynchornously ,get list of analysis uns that is scheduled using runAnalysis:WithCompletionBlock for a pkg version. The
 execution results ARE
 NOT cached. The details of result of the run can be fetcged using getExecutionResultsForAnalysisRun:WithCompletionBlock

 @param pkgVersion The Id of pkg Version for which analysis runs are to be fetched

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, the results
 of analysis run results is returned in the handler

 @see -signIntoAccount:withCompletionBlock:

 @see -runAnalysis:WithCompletionBlock:

 @see analysesManager


 */
- (void)getAnalysisRunResultsForPkgVersion:(NSNumber *)pkgVersion
                       WithCompletionBlock:(void (^)(INVAnalysisRunArray analysisruns, INVEmpireMobileError *error))handler;

/**
 Asynchornously ,get result of specified analysis run that is scheduled using runAnalysis:WithCompletionBlock. The execution
 results ARE NOT cached

 @param analysisRunId The Id of analysisrun Id for which the execution results are to be fetched. Retrieved using
 getAnalysisRunResultsForPkgVersion:WithCompletionBlock

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, thearray of
 INVAnalysisRunResult objects is returned

 @see -signIntoAccount:withCompletionBlock:

 @see -getAnalysisRunResultsForPkgVersion:WithCompletionBlock

 @see analysesManager


 */
- (void)getExecutionResultsForAnalysisRun:(NSNumber *)analysisRunId
                      WithCompletionBlock:(void (^)(INVAnalysisRunResultsArray response, INVEmpireMobileError *error))handler;

/**
 Asynchornously ,get list of issues for Execution result corresponding to an analysis run . The execution
 result issuesARE NOT cached

 @param runResultsId The Id of run result Id for which the execution issues are to be fetched. Retrieved using
 getExecutionResultsForAnalysisRun:WithCompletionBlock

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, thearray of
 INVAnalysisRunDetail objects is returned

 @see -signIntoAccount:withCompletionBlock:

 @see -getExecutionResultsForAnalysisRun:WithCompletionBlock

 @see analysesManager


 */
- (void)getIssuesForExecutionResult:(NSNumber *)runResultsId
                WithCompletionBlock:(void (^)(INVRuleIssueArray response, INVEmpireMobileError *error))handler;

/**
 Asynchornously , fetch details of issues for specified Id. This returns the list of building element details

 The user must have succesfully into the account via signIntoAccount:withCompletionBlock: . The results are NOT cached.

 @param issueId The Id of the issue whose details are to be fetched. Retrieved using
 getIssuesForExecutionResult:WithCompletionBlock

 @param handler The completion handler that returns error object if there was any error. If no error, building elements  are
 returned

 @see analysesManager

 */
- (void)fetchBuildingElementDetailsForIssue:(NSNumber *)issueId withCompletionBlock:(CompletionHandlerWithData)handler;

#pragma mark - General Account Related
/**
 Removes any user /account information persisted for the user.An error is not returned  if user has not signed in

 @param handler The completion handler that returns error object if there was any error.

 */
- (void)logOffSignedInUserWithCompletionBlock:(CompletionHandler)handler;

/**
 Removes any account information persisted for the user. User will continue to remain signed in . An error is not returned  if
 user has not signed in

 @param handler The completion handler that returns error object if there was any error.

 */
- (void)logOffSignedInAccountWithCompletionBlock:(CompletionHandler)handler;

#pragma mark - Misc
/**
 Convenience method that retuns a NSURLRequest to fetch the system configuration. If there is an error, a nil value is returned

 */
+ (NSURLRequest *)requestToFetchSystemConfiguration;

/**
 Convenience method that retuns the possible account membership roles

 @see INVMembership

 */

+ (INVMembershipTypeDictionary)membershipRoles;

/**
 Convenience method that retuns the possible analysis run statuses

 @see INVAnalyisRunDetails

 */

+ (INVANalysisRunStatusDictionary)analysisRunStatusMap;

@end
