//
//  INVAnalysesManager.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//@import Foundation;
//@import CoreData;

#import "INVAnalysis.h"
#import "INVRule.h"
#import "INVRuleInstance.h"
#import "INVAnalysisPkgMembership.h"

@interface INVAnalysesManager : NSObject

/**
 The managed object context - Use this in conjunction with the various NSFetchRequests to handle fetching and processing of data
 */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 Can be used to obtain information on rule sets
 */
@property (nonatomic, readonly, copy) NSFetchRequest *fetchRequestForAnalyses;

/**
 Can be used to obtain information on rules
 */
@property (nonatomic, readonly, copy) NSFetchRequest *fetchRequestForRules;

/**
 Can be used to obtain information on rule instances
 */
@property (nonatomic, readonly, copy) NSFetchRequest *fetchRequestForRuleInstance;

/**
 Creates a singleton instance of INVAnalysesManager.

 @note Instances of INVAnalysesManager are exclusively created and managed by INVMobileClient. Applications MUST NOT create and
 manage instances of this class but
 instance refer to rulesManager property of INVEmpireMobileClient

 @param managedContext Context for managing data

 @see INVMobileClient

 @return The singleton instance
 */
+ (instancetype)sharedInstanceWithManagedContext:(NSManagedObjectContext *)managedContext;

/**
 Returns cached analyses corresponding to a specific project

 @param projectId projectId for which rule sets are to be fetched

 @see INVANalysis

 @return The array of INVAnalysis objects
 */
- (INVAnalysisArray)analysesForProject:(NSNumber *)projectId;

/**
 Returns cached analyses corresponding to a specific pkg master
 
 @param pkgMasterId pkgMasterId for which rule sets are to be fetched
 
 @see INVANalysis
 
 @return The array of INVAnalysis objects
 */
- (INVAnalysisArray)analysesForPkgMaster:(NSNumber *)pkgMasterId;


/**
 Returns analyses objects given list of  for analysisIds
  @param analysesIds Ids for which analyses objects are to be fetched

 @see INVMobileClient

 @return The array of INVAnalyses objects corresponding to the list of analysisIds
 */
- (INVAnalysisArray)analysesForIds:(NSArray *)analysesIds;

/**
 Returns rule definitions for current account for specific ruleId

 @see INVRule

 @return The array of INVRule objects
 */
- (INVRuleArray)ruleDefinitionsForSignedInAccount;

/**
 Returns rule definition for specific ruleId

 @param ruleId ruleId for which rule definition is to be fetched

 @see INVRule

 @return The array of INVRule objects
 */
- (INVRule *)ruleDefinitionForRuleId:(NSNumber *)ruleId;

/**
 Returns rule instance for specific ruleinstanceId

 @param ruleInstanceId Id for rule instance

 @param analysisId Id for analysis


 @see INVRuleInstance

 @return The rule instance
 */
- (INVRuleInstance *)ruleInstanceForRuleInstanceId:(NSNumber *)ruleInstanceId forAnalysisId:(NSNumber *)analysisId;

/**
 Returns list of pkg master Ids for given analyses. Details of the packages can be retrieved via the INVProjectManager

 @param analysisId Id for analysis

 @see INVPackage

 @see INVProjectManager

 @return The array of pkg masters
 */
- (NSSet *)pkgMastersForAnalysisId:(NSNumber *)analysisId;

/**
 Returns list of membershipIds for given array of analysisIds.

 @param analysisId Id for analysis

 @return The array of INVAnalysisPkgMembership objects
 */
- (INVAnalysisPkgMembershipArray)membershipIdsForAnalysisIds:(NSArray *)analysisIds;


/**
 Returns list of membershipIds for given array of pkg VersionIds.
 
 @param pkgVersionId Id for pkg versions
 
 @return The array of INVAnalysisPkgMembership objects
 */
- (INVAnalysisPkgMembershipArray)membershipIdsForPkgVersionIds:(NSArray *)pkgVersionIds;

/**
 Returns list of analysesIds for given pkg master

 @param pkgMasterId the Id of the pkg master

 @return The array of analyses Ids
 */
- (NSSet *)analysesIdsForPkgMaster:(NSNumber *)pkgMasterId;

/**
 Returns list of analysesIds for given pkg master
 
 @param pkgMasterId the Id of the pkg master
 
 @return The array of analyses Ids
 */
- (NSSet *)analysesIdsForPkgMaster:(NSNumber *)pkgMasterId;

/*
 Removes rule instance from local cache and updates corresponding analyses object
 */

- (NSError *)removeCachedRuleInstanceForInstanceId:(NSNumber *)ruleInstanceId;

@end
