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




typedef void(^CompletionHandler)(INVEmpireMobileError* error);

@interface INVEmpireMobileClient : NSObject
/**
 The XOS Passport server address
 */
@property (nonatomic,readonly,copy)NSString* passportServer;

/**
 The Empire Manage Server
 */
@property (nonatomic,readonly,copy)NSString* empireManageServer;


/**
 Account Manager resposible for managing responses to account related requests
 */
@property (nonatomic,readonly)INVAccountManager* accountManager;

/**
 Project Manager resposible for managing responses to project related requests
 */
@property (nonatomic,readonly)INVProjectManager* projectManager;

/**
 Rules Manager resposible for managing responses to rules related requests
 */
@property (nonatomic,readonly)INVRulesManager* rulesManager;


#pragma mark - Creation
/**
 Creates a singleton instance of EmporeMobileClient and initializes it with the XOS Passport server 
 
 @param passportServer The address of the passport server (eg.127.0.0.1, localhost, www.server.com)
 
 @param port The port of passport server. This is optional and defaults to 8080
 
 @return The singleton instance
 */
+(INVEmpireMobileClient*)sharedInstanceWithXOSPassportServer:(NSString*)passportServer andPort:(NSString*)port;

/**
 Creates a singleton instance of EmporeMobileClient and initializes it with the XOS Passport server
 
 NOTE: This is used exclusively in test mode so cached data is all in-memory
 
 @param passportServer The address of the passport server (eg.127.0.0.1, localhost, www.server.com)
 
 @param port The port of passport server. This is optional and defaults to 8080
 
 @return The singleton instance
 */
+(INVEmpireMobileClient*)sharedTestInstanceWithXOSPassportServer:(NSString*)passportServer andPort:(NSString*)port;

/**
 Configures EmpireMobileClient with server address and port
 
 @param server The address of the Empire Manage server (eg.127.0.0.1, localhost, www.server.com)
 
 @param port The port of Empire Manage server. This is optional and defaults to 8080.
 
 */
-(void)configureWithEmpireManageServer:(NSString*)server andPort:(NSString*)port;


#pragma mark - User/Account Management
/**
 Asynchornously ,sign into the XOS Passport service with given email address and password. The user should be registered through the Empire Web website.
 
 @param userName The email address of user
 
 @param password The password of user
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then accountManager can be used to retrieve the token of the signed in user.
 
 @see accountManager 

 
 */
-(void)signInWithUserName:(NSString*)userName andPassword:(NSString*)password withCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously ,get list of all accounts associated with signed in user. 
 
 @param userName The email address of user
 
 @param password The password of user
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then accountManager can be used to retrieve accounts
 
 @see -signInWithUserName:andPassword:withCompletionBlock:
 
 @see accountManager
 
 */
-(void)getAllAccountsForSignedInUserWithCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously ,sign into specific Empire Manage account via the  XOS Passport service.The user should have signed in via signInWithUserName:andPassword:withCompletionBlock
 
 @param accountId The account Id
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then accountManager can be used to retrieve the account token
 
 @see accountManager
 
 @see -signInWithUserName:andPassword:withCompletionBlock:
 
 */
-(void)signIntoAccount:(NSNumber*)accountId withCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously ,get profile of signed in user
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then accountManager can be used to retrieve the signed in user profile info
 
 @see -signInWithUserName:andPassword:withCompletionBlock:
 
 @see accountManager
 
 
 */
-(void)getSignedInUserProfileWithCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously ,get list of members belonging to specified account If the request is made on behalf of admin user, then the list of accounts that a user is a member of is
 also returned. The user must have succesfully used in via signIntoAccount:withCompletionBlock
 
 @param accountId The account Id

 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then accountManager can be used to retrieve the account membership info
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see accountManager

 
 */
-(void)getMembershipForAccount:(NSNumber*)accountId withCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously , invite list of users to currently signed in account.  The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param emails List of one or more email addresses of users to invite
 
 @param handler The completion handler that returns error object if there was any error. 
 
 @see -signIntoAccount:withCompletionBlock:
 
*/
-(void)inviteUsersToSignedInAccount:(NSArray*)emails withCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously, fetch list of invites for user for signed in account.  The user must have succesfully into the account via signIntoAccount:withCompletionBlock: to view invites for the account. If success, the list of invites
 can be retrieved using the accountManager
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see accountManager
 
 */
-(void)getPendingInvitationsSignedInAccountWithCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously, fetch list of invites for user.  The user must have succesfully into the account via signInWithUserName:andPassword:withCompletionBlock to view invites for the user. If success, the list of invites
 can be retrieved using the accountManager
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signInWithUserName:andPassword:withCompletionBlock
 
 @see accountManager
 
 */
-(void)getPendingInvitationsForSignedInUserWithCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously, accept invite for user.  The user must have succesfully into the account via signIntoAccount:withCompletionBlock: to view invites for the account. The list of pending invitations can be retrieved using getPendingInvitationsForSignedInUserWithCompletionBlock: call.
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see accountManager
 
 */
-(void)acceptInvite:(NSString*)invitationCode withCompletionBlock:(CompletionHandler) handler;


#pragma mark - Projects Related

/**
 Asynchornously ,get list of all projects for signed in account. Users should have signed in via the signIntoAccount:withCompletionBlock: method.
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil,  then projectManager can be used to retrieve projects
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see projectManager
 
 */
-(void)getAllProjectsForSignedInAccountWithCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously ,get list of all files associated with a project. Users must have signed into an account in order to be able to fetch project files.
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then projectManager can be used to retrieve projects
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see projectManager
 
 */
-(void)getAllFilesForProject:(NSNumber*)projectId WithCompletionBlock:(CompletionHandler) handler;


#pragma mark - Rules Related
/**
 Asynchornously ,get list of all rulesets associated with a project. Users must have signed into an account in order to be able to fetch rule sets.
 
 @param projectId The id of the project
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve rulesets
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see rulesManager
 
 */
-(void)getAllRuleSetsForProject:(NSNumber*)projectId WithCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously ,get list of all rulesets associated with a file. Users must have signed into an account in order to be able to fetch rule sets.
 
 @param fileId The Id of the file master for which rulesets are to be fetched
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve rulesets
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see rulesManager
 
 */
-(void)getAllRuleSetsForFile:(NSNumber*)fileId WithCompletionBlock:(CompletionHandler) handler;



#pragma mark - Rules Related
/**
 Asynchornously ,get list of all rules associated with a account. Users must have signed into an account in order to be able to fetch rules.
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve rules
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see rulesManager
 
 */
-(void)getAllRuleDefinitionsForSignedInAccountWithCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously ,get rule definition associated with specific ruleId. Users must have signed into an account in order to be able to fetch rules.
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve rules
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see rulesManager
 
 */
-(void)getRuleDefinitionForRuleId:(NSNumber*)ruleId WithCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously ,get list of all file masters associated with a ruleset. Users must have signed into an account in order to be able to fetch file masters.
 
 @param ruleSet The ruleset for which the file masters need to be fetched
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve files for the project
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see rulesManager
 
 */
-(void)getAllFileMastersForRuleSet:(NSNumber*)ruleSet WithCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously , update the list of files associated with a ruleset  The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param ruleSetId  The rule set Id
 
 @param fileMasters The list of file masters to be associated with the rule set
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 */
-(void)updateRuleSet:(NSNumber*)ruleSetId withFileMasters:(NSArray*)fileMasters withCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously , update the list of rulesets associated with a file  The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param fileId  The file Id
 
 @param rulesetIds The list of ruleset Ids to be associated with the f
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 */
-(void)updateFileId:(NSNumber*)fileId withRuleSets:(NSArray*)rulesetIds withCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously , execute a ruleset against a model. All rule instances within rule set will be executed. The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param ruleSetId  The Id of the ruleset
 
 @param modelId the Id of the model
  
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 */
-(void)executeRuleSet:(NSNumber*)ruleSetId againstModel:(NSNumber*)modelId withCompletionBlock:(CompletionHandler) handler;




#warning Include way to asyncronously Notify when log out is done
/**
 Removes any user /account information persisted for the user.An error is not returned  if user has not signed in
 
 @param handler The completion handler that returns error object if there was any error.
 
 */
-(void)logOffSignedInUserWithCompletionBlock:(CompletionHandler) handler;

/**
 Removes any account information persisted for the user. User will continue to remain signed in . An error is not returned  if user has not signed in
 
 @param handler The completion handler that returns error object if there was any error.
 
 */
-(void)logOffSignedInAccountWithCompletionBlock:(CompletionHandler) handler;

@end
