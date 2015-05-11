//
//  INVRuleExecutionManager.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 12/22/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

//@import Foundation;
//@import CoreData;

@interface INVRuleExecutionManager : NSObject

/**
 The managed object context - Use this in conjunction with the various NSFetchRequests to handle fetching and processing of data
 */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 Can be used to obtain information on rule instance executions
 */
@property (nonatomic, readonly, copy) NSFetchRequest *fetchRequestForRuleInstanceExecutions;

/**
 Creates a singleton instance of INVRuleExecutionManager.

 @note Instances of INVRulesManager are exclusively created and managed by INVMobileClient. Applications MUST NOT create and
 manage instances of this class but
 instance refer to rulesManager property of INVEmpireMobileClient

 @param managedContext Context for managing data

 @see INVMobileClient

 @return The singleton instance
 */
+ (instancetype)sharedInstanceWithManagedContext:(NSManagedObjectContext *)managedContext;

/**
 Returns list of all rule executions.

 @see INVRuleInstanceExecution

 @return The array of all rule executions
 */
- (NSArray *)allRuleExecutions;

/**
 Returns list of all rule executions for a file version.

 @param fileVersionId The Id of the file version

 @see INVRuleInstanceExecution

 @return The array of all rule executions for file version
 */
- (NSArray *)allRuleExecutionsForPackageVersion:(NSNumber *)pkgVersionId;

/**
 Returns list of all rule executions for a rule instance

 @param ruleInstanceId The Id of the rule instance

 @see INVRuleInstanceExecution

 @return The array of all rule executions for rule instance Id
 */
- (NSArray *)allRuleExecutionsForRuleInstance:(NSNumber *)ruleInstanceId;

/**
 Returns list of all rule executions for a group tag Id

 @param groupTagId The Id of the group

 @see INVRuleInstanceExecution

 @return The array of all rule executions for group Tag Id
 */
- (NSArray *)allRuleExecutionsForGroupTagId:(NSString *)groupTagId;

#warning Include way to asyncronously Notify when deletion is done

/**
 Removes all persisted rules executions information.
 @return  nil if there was no error deleting user data else appropriate error object.
 */
- (NSError *)removeAllRuleExecutionsCachedData;
@end
