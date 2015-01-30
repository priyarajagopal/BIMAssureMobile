//
//  INVRulesManager.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

@import Foundation;
@import CoreData;

#import "INVRuleSet.h"
#import "INVRule.h"
#import "INVRuleInstance.h"


@interface INVRulesManager : NSObject

/**
 The managed object context - Use this in conjunction with the various NSFetchRequests to handle fetching and processing of data
 */
@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;


/**
 Can be used to obtain information on rule sets
 */
@property (nonatomic,readonly,copy) NSFetchRequest* fetchRequestForRuleSets;

/**
 Can be used to obtain information on rules
 */
@property (nonatomic,readonly,copy) NSFetchRequest* fetchRequestForRules;

/**
 Can be used to obtain information on ruleset to files mapping
 */
@property (nonatomic,readonly,copy) NSFetchRequest* fetchRequestForRuleSetToFilesMap;

/**
 Can be used to obtain information on file to rulesets mapping
 */
@property (nonatomic,readonly,copy) NSFetchRequest* fetchRequestForFileToRuleSetsMap;


/**
 Creates a singleton instance of INVRulesManager.
 
 @note Instances of INVRulesManager are exclusively created and managed by INVMobileClient. Applications MUST NOT create and manage instances of this class but
 instance refer to rulesManager property of INVEmpireMobileClient
 
 @param managedContext Context for managing data
 
 @see INVMobileClient
 
 @return The singleton instance
 */
+(instancetype)sharedInstanceWithManagedContext:(NSManagedObjectContext*)managedContext;

/**
 Returns rule sets corresponding to a specific project
 
 @param projectId projectId for which rule sets are to be fetched
 
 @see INVRuleSet
 
 @return The array of INVRuleSet objects
 */
-(INVRuleSetArray) ruleSetsForProject:(NSNumber*)projectId;

/**
 Returns rule definitions for current account for specific ruleId
 
 @see INVRule
 
 @return The array of INVRule objects
 */
-(INVRuleArray) ruleDefinitionsForSignedInAccount;


/**
 Returns rule definition for specific ruleId
 
 @param ruleId ruleId for which rule definition is to be fetched
 
 @see INVRule
 
 @return The array of INVRule objects
 */
-(INVRule*) ruleDefinitionForRuleId:(NSNumber*)ruleId;



/**
 Returns rule instance for specific ruleinstanceId
 
 @param ruleInstanceId Id for rule instance
 
 @param ruleId ruleId of rule
 
 
 @see INVRuleInstance
 
 @return The rule instance
 */
-(INVRuleInstance*) ruleInstanceForRuleInstanceId:(NSNumber*)ruleInstanceId forRuleSetId:(NSNumber*)ruleSetId;


/**
 Returns rule sets for signed in account
 
 @see INVRule
 
 @return The array of INVRuleSet objects
 */
-(INVRuleSetArray) ruleSetsForSignedInAccount;



/**
 Returns rulesets for rulesetIds
 
 @see INVMobileClient
 
 @return The array of INVRuleSet objects corresponding to the list of rulesetIds
 */
-(INVRuleSetArray)ruleSetsForIds:(NSArray*)ruleSetIds;

/**
 Returns list of pkg master Ids. Details of the packages can be retrieved via the INVProjectManager
 
 @param ruleSetId Id for rule set
 
 @see INVPackage
 
 @see INVProjectManager
 
 @return The array of rule Ids
 */
-(NSSet*)pkgMastersForRuleSetId:(NSNumber*)ruleSetId;


/**
 Returns list of ruleSetIds. Details of the rules can be retrieved via the fetchRequestForRules
 
 @param fileId for rule set
 
 @see INVPackage
 
 @see fetchRequestForRules
 
 @return The array of rule sets
 */
-(NSSet*)ruleSetIdsForPkgMaster:(NSNumber*)fileId;


/**
 Update local cache of rule instance with specified Id
 
 @param ruleInstanceId The id of the rule Instance
 
 @param ruleId The Id of the rule definition corresponding to the instance
 
 @param ruleName The name of the tule
 
 @param overview The rule description
 
 @param actualParams A dictionary of key:value pairs representing the actual parameters for the given instance
 
 @return  YES if success else NO
 */
-(BOOL)updateCachedRuleInstanceForRuleInstanceId:(NSNumber*)ruleInstanceId forRuleId:(NSNumber*)ruleId inRuleSetId:(NSNumber*)ruleSetId withRuleName:(NSString*)ruleName andDescription:(NSString*)overview andActualParameters:(INVRuleInstanceActualParamDictionary)actualParams;

/**
 Remove package master associated with a rule set Id from local cache
 @param ruleSetId The Id of rule set to be updated
 
 @param pkgMasterId the Id of Pkg master to be removed
 
 @return nil is success or error object
 */
-(NSError*)removeFromLocalCacheRuleSet:(NSNumber*)ruleSetId associatedWithPkgMaster:(NSNumber*)pkgMasterId;


/**
 Remove rulesetId  associated with a package master from local cache
 
 @param ruleSetId The Id of rule set to be updated
 
 @param pkgMasterId the Id of Pkg master to be removed
 
 @return nil is success or error object
 */
-(NSError*)removeFromLocalCachePkgMasterId:(NSNumber*)pkgMasterId associatedWithRuleSet:(NSNumber*)ruleSetId;



#warning Include way to asyncronously Notify when deletion is done
/**
 Removes cached rule instance for instance Id
 @return  nil if there was no error deleting user data else appropriate error object.
 */
-(NSError*)removeCachedRuleInstanceForInstanceId:(NSNumber*)ruleInstanceId;


/**
 Removes all persisted rules information pertaining to a project. Although the deletion is initated , a nil error response does not necessarily imply that all data was
 removed as requested.
 @return  nil if there was no error deleting user data else appropriate error object.
 */
-(NSError*)removeCachedRulesDataForProject:(NSNumber*)projectId;

/**
 Removes all persisted rules information. Although the deletion is initated , a nil error response does not necessarily imply that all data was
 removed as requested.
 @return  nil if there was no error deleting user data else appropriate error object.
 */
-(NSError*)removeAllRulesCachedData;


/**
 Removes all persisted ruleset to file mapping information. Although the deletion is initated , a nil error response does not necessarily imply that all data was
 removed as requested.
 @return  nil if there was no error deleting user data else appropriate error object.
 */
-(NSError*)removeAllRuleSetsToFileMappingCachedData;

/**
 Removes all persisted files to ruleset mapping information. Although the deletion is initated , a nil error response does not necessarily imply that all data was
 removed as requested.
 @return  nil if there was no error deleting user data else appropriate error object.
 */
-(NSError*)removeAllFilesToRuleSetMappingCachedData;
@end
