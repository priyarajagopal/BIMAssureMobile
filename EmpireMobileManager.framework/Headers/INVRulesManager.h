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
#import "INVRuleInstance.h"
#import "INVRule.h"

@interface INVRulesManager : NSObject

/**
 The managed object context - Use this in conjunction with the various NSFetchRequests to handle fetching and processing of data
 */
@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;


/**
 Can be used to obtain information on rule sets
 */
@property (nonatomic,readonly) NSFetchRequest* fetchRequestForRuleSets;

/**
 Can be used to obtain information on rules
 */
@property (nonatomic,readonly) NSFetchRequest* fetchRequestForRules;

/**
 Can be used to obtain information on ruleset to files mapping
 */
@property (nonatomic,readonly) NSFetchRequest* fetchRequestForRuleSetToFilesMap;


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
 Returns rule for current account for specific ruleId
 
 @see INVRule
 
 @return The array of INVRule objects
 */
-(INVRuleArray) rulesForSignedInAccount;


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
 Returns list of fileIds. Details of the files can be retrieved via the INVProjectManager
 
 @param ruleSetId Id for rule set
 
 @see INVFile
 
 @see INVProjectManager
 
 @return The array of rule Ids
 */
-(NSArray*)fileMasterIdsForRuleSetId:(NSNumber*)ruleSetId;

#warning rename API "delete" to be "removeCached..."

#warning Include way to asyncronously Notify when deletion is done
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
@end
