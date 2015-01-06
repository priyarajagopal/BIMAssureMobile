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
#import "INVRuleExecutionManager.h"
#import "INVRuleInstanceExecution.h"
#import "INVBuildingManager.h"

/**
 Completion Handler that returns the status of the request. In case of no error, the appropriate Data Manager (INVAccountManager, INVProjectManager...) can be  queried for the cached results.
 The results of the corresponding requests are not cached.
 */
typedef void(^CompletionHandler)(INVEmpireMobileError* error);

/**
 Completion Handler that returns the status of the request as well the data (if any). The results of the corresponding requests are not cached.
 */
typedef void(^CompletionHandlerWithData)(id result, INVEmpireMobileError* error);


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


/**
 Rule execution Manager resposible for managing responses to rule execution related requests
 */
@property (nonatomic,readonly)INVRuleExecutionManager* ruleExecutionManager;

/**
 Building Manager resposible for managing responses to building related requests
 */
@property (nonatomic,readonly)INVBuildingManager* buildingManager;


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


/**
 Asynchornously, remove user with specified userId from account. Only admins are allowed to exercise this call.
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see accountManager
 
 */
-(void)removeUser:(NSNumber*)userId fromAccount:(NSNumber*)accountId withCompletionBlock:(CompletionHandler) handler;



/**
 Asynchornously , sign up for a user account with the XOS Passport service
 
 @param userName The full name of user
 
 @param email The email address of user
 
 @param password The password of user
 
 @param accountName Name of account to be created
 
 @param accountDescription An optional description of account
 
 @param type Subscription type Will always be mapped to 1 for now
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then accountManager can be used to retrieve the details of account
 
 @see accountManager
 
 
 */
-(void)signUpUserWithName:(NSString*)userName andEmail:(NSString*)email andPassword:(NSString*)password withAccountName:(NSString*)accountName accountDescription:(NSString*)accountDescription subscriptionType:(NSNumber*)type withCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously , create an account for currently signed in user with the XOS Passport service
 
 @param accountName Name of account to be created
 
 @param accountDescription An optional description of account
 
 @param type Subscription type Will always be mapped to 1 for now
 
 @param userEmail The email address of signed in user. ***** THE SERVER API SHOULD BE UPDATED TO NOT REQUIRE THIS FIELD ******
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then accountManager can be used to retrieve the details of account
 
 @see accountManager
 
 
 */
-(void)createAccountForSignedInUserWithAccountName:(NSString*)accountName accountDescription:(NSString*)accountDescription subscriptionType:(NSNumber*)type forUserEmail:(NSString*)userEmail withCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously , update details of specified account with the XOS Passport service
 
 @param accountName updated name of account
 
 @param accountDescription Updated optional description of account
 
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then accountManager can be used to retrieve the details of account
 
 @see accountManager
 
 
 */
-(void)updateAccountWithAccountId:(NSNumber*)accountId withAccountName:(NSString*)accountName accountDescription:(NSString*)accountDescription withCompletionBlock:(CompletionHandler) handler;



#pragma mark - project management

/**
 Asynchornously ,create project with specified name. Only an admin is capable of exercising this call.
 
 @param projectName name of project
 
 @param overview Description of project (currently unused in backend)
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 */
-(void)createProjectWithName:(NSString*)projectName andDescription:(NSString*)overview ForSignedInAccountWithCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously ,edit project with specified Id. Only an admin is capable of exercising this call. This API is not supported in
 the backend
 
 @param projectId The Id of project to be updated
 
 @param projectName updated name of project
 
 @param overview updated Description of project (currently unused in backend)
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 */
-(void)updateProjectWithId:(NSNumber*)projectId withName:(NSString*)projectName andDescription:(NSString*)overview ForSignedInAccountWithCompletionBlock:(CompletionHandler) handler;



#pragma mark - Model Related

/**
 Asynchornously, fetch the JSON corresponding to the model from the server. The model data is NOT locally cached
 
 @param handler The completion handler that returns error object if there was any error. If error is nil, it returns the JSON model data
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see accountManager
 
 */
-(void)fetchModelViewForId:(NSNumber*)modelId withCompletionBlock:(CompletionHandlerWithData) handler;

/**
 Convenience method that retuns a NSURLRequest to fetch the JSON model data. This provides the flexibility for clients to fetch and process the data
 as they choose to. If there is an error, a nil value is returned
 
 @param pkgVersion the Id of the model whose JSON data is to fetched
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see accountManager
 
 */
-(NSURLRequest*)requestToFetchModelViewForId:(NSNumber*)pkgVersion ;



/**
 Convenience method that retuns a NSURLRequest to fetch the JSON model data. This provides the flexibility for clients to fetch and process the data
 as they choose to. If there is an error, a nil value is returned
 
 @param modelId the Id of the model whose JSON data is to fetched
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see accountManager
 
 */
-(NSURLRequest*)requestToFetchModelViewForId:(NSNumber*)modelId ;




/**
 Convenience method that retuns a NSURLRequest to fetch the JSON model data. This provides the flexibility for clients to fetch and process the data
 as they choose to. If there is an error, a nil value is returned
 
 @param modelId the Id of the model whose JSON data is to fetched
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see accountManager
 
 */
-(NSURLRequest*)requestToFetchModelViewForId:(NSNumber*)modelId ;


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
-(void)getAllPkgMastersForProject:(NSNumber*)projectId WithCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously ,get list of all rulesets associated with a project. Users must have signed into an account in order to be able to fetch rule sets.
 
 @param projectId The id of the project
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve rulesets
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see rulesManager
 
 */
-(void)getAllRuleSetsForProject:(NSNumber*)projectId WithCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously ,delete a project for signed in account. Users should have signed in via the signIntoAccount:withCompletionBlock: method.
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 
 */
-(void)deleteProjectWithId:(NSNumber*)projectId ForSignedInAccountWithCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously ,get thumbnail image for specified package versionId. Users should have signed in via the signIntoAccount:withCompletionBlock: method.
 
 @param pkgVersionId Package Version Id
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 
 */
-(void)getThumbnailImageForPkgVersion:(NSNumber*)pkgVersionId ForSignedInAccountWithCompletionBlock:(CompletionHandlerWithData) handler;


#pragma mark - Rule Sets Membership Related


/**
 Asynchornously ,get list of all package masters associated with a ruleset. Users must have signed into an account in order to be able to fetch file masters.
 
 @param ruleSetId The ruleset for which the file masters need to be fetched
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve files for the project
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see rulesManager
 
 */
-(void)getAllPkgMastersForRuleSet:(NSNumber*)ruleSetId WithCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously , add the list of package masters to a ruleset. The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param ruleSetId  The rule set Id
 
 @param pkgMasters The list of file masters to be associated with the rule set
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 */
-(void)addToRuleSet:(NSNumber*)ruleSetId pkgMasters:(NSArray*)pkgMasters withCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously , remove pkgMaster from rule set. The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param ruleSetId  The rule set Id
 
 @param pkgMasterId The Id of Pkg master to be removed
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 */
-(void)removeFromRuleSet:(NSNumber*)ruleSetId pkgMaster:(NSNumber*)pkgMasterId withCompletionBlock:(CompletionHandler) handler;

#pragma mark - Package Membership Related

/**
 Asynchornously ,get list of all rulesets associated with a file. Users must have signed into an account in order to be able to fetch rule sets.
 
 @param pkgMasterId The Id of the file master for which rulesets are to be fetched
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve rulesets
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see rulesManager
 
 */
-(void)getAllRuleSetMembersForPkgMaster:(NSNumber*)pkgMasterId WithCompletionBlock:(CompletionHandler) handler;



/**
 Asynchornously , add the list of rulesets associated with a pkg master  The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param pkgMasterId  The Id of Pkg master
 
 @param rulesetIds The list of ruleset Ids to be associated with the package
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 */
-(void)addToPkgMaster:(NSNumber*)pkgMasterId ruleSets:(NSArray*)rulesetIds withCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously , remove the list of package masters to a ruleset. The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param pkgMasterId  The Id of Pkg master
 
 @param ruleSetId  The rule set Id to be removed
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 */
-(void)removeFromPkgMaster:(NSNumber*)pkgMasterId ruleSet:(NSNumber*)ruleSetId  withCompletionBlock:(CompletionHandler) handler;

#pragma mark - Rule Instances management


/**
 Asynchornously ,create a specified rule instance.
  
 @param ruleId The Id of the rule definition corresponding to the instance
 
 @param ruleName The name of the tule
 
 @param overview The rule description
 
 @param actualParams A dictionary of key:value pairs representing the actual parameters for the given instance
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve rulesets
 
 @see -signIntoAccount:withCompletionBlock:
 
 
 */
-(void)createRuleInstanceForRuleId:(NSNumber*)ruleId inRuleSetId:(NSNumber*)ruleSetId withRuleName:(NSString*)ruleName andDescription:(NSString*)overview andActualParameters:(INVRuleInstanceActualParamDictionary)actualParams WithCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously ,update the specified rule instance.
 
 @param ruleInstanceId The id of the rule Instance
 
 @param ruleId The Id of the rule definition corresponding to the instance
 
 @param ruleName The name of the tule
 
 @param overview The rule description
 
 @param actualParams A dictionary of key:value pairs representing the actual parameters for the given instance
 
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve rulesets
 
 @see -signIntoAccount:withCompletionBlock:
 
 
 */
-(void)modifyRuleInstanceForRuleInstanceId:(NSNumber*)ruleInstanceId forRuleId:(NSNumber*)ruleId inRuleSetId:(NSNumber*)ruleSetId withRuleName:(NSString*)ruleName andDescription:(NSString*)overview andActualParameters:(INVRuleInstanceActualParamDictionary)actualParams WithCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously ,delete the specified rule instance.
 
 @param ruleInstanceId The id of the rule Instance
 @param handler The completion handler that returns error object if there was any error. If error parameter is nil, then rulesManager can be used to retrieve rulesets
 
 @see -signIntoAccount:withCompletionBlock:
 
 
 */
-(void)deleteRuleInstanceForId:(NSNumber*)ruleInstanceId WithCompletionBlock:(CompletionHandler) handler; 



#pragma mark - Rules Definition Related
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


#pragma mark - Rules Execution Related
/**
 Asynchornously , execute a ruleset against a pkg version . All rule instances within rule set will be executed. The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param ruleSetId  The Id of the ruleset
 
 @param packageVersionId The Id of the file version
   
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see ruleExecutionManager
 
 */
-(void)executeRuleSet:(NSNumber*)ruleSetId againstPackageVersionId:(NSNumber*)pkgVersionId withCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously , execute a specific rule instance against a pkg version.  The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param ruleInstanceId  The Id of the rule instance
 
 @param pkgVersionId The Id of the file version
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see -signIntoAccount:withCompletionBlock:
 
 @see ruleExecutionManager
 
 */
-(void)executeRuleInstance:(NSNumber*)ruleInstanceId againstPackageVersionId:(NSNumber*)pkgVersionId withCompletionBlock:(CompletionHandler) handler;


/**
 Asynchornously , fetch  the executions scheduled on a package version . Every execution that is scheduled via executeRuleInstance:againstFileVersionId:againstModel:withCompletionBlock
 and executeRuleSet:againstFileVersionId:againstModel:withCompletionBlock  will be associated with a unique GroupTag. The execution results are available via INVRulesManager.
 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 
 @param pkgVersionId The Id of the package version
 
 @param handler The completion handler that returns error object if there was any error.
 
 @see rulesManager
 
 @see -executeRuleSet:againstFileVersionId:againstModel:withCompletionBlock:
 
 @see -executeRuleInstance:againstFileVersionId:againstModel:withCompletionBlock:

 */
-(void)fetchRuleExecutionsForPackageVersionId:(NSNumber*)pkgVersionId withCompletionBlock:(CompletionHandler) handler;


#pragma mark - Model/Building Related
/**
 Asynchornously , fetch details of issues for specified Id
 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param issueId The Id of the issue whose details are to be fetched
 
 @param handler The completion handler that returns error object if there was any error. If no error, details can be queried via the INVRuleExecutionsManager interface
 
 @see ruleExecutionsManager
 
 */
-(void)fetchIssueDetailsForId:(NSNumber*)issueId withCompletionBlock:(CompletionHandler) handler;

/**
 Asynchornously , fetch details of issues for specified Id
 The user must have succesfully into the account via signIntoAccount:withCompletionBlock:
 
 @param issueId The Id of the issue whose details are to be fetched
 
 @param handler The completion handler that returns error object if there was any error. If no error, details can be queried via the INVRuleExecutionsManager interface
 
 @see ruleExecutionsManager
 
 */
-(void)fetchBuildingElementDetailsForId:(NSNumber*)elementId withCompletionBlock:(CompletionHandler) handler;

#pragma mark - General Account Related

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


#pragma mark - Misc
/**
 Convenience method that retuns a NSURLRequest to fetch the system configuration. If there is an error, a nil value is returned

 */
+(NSURLRequest*)requestToFetchSystemConfiguration;
    


@end
