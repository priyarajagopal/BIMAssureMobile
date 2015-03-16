//
//  INVAnalysesManager.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 3/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Foundation;
@import CoreData;

#import "INVAnalysis.h"
#import "INVRule.h"
#import "INVRuleInstance.h"

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
 Returns analyses corresponding to a specific project

 @param projectId projectId for which rule sets are to be fetched

 @see INVANalysis

 @return The array of INVRuleSet objects
 */
- (INVAnalysisArray)analysesForProject:(NSNumber *)projectId;

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
- (INVRuleInstance *)ruleInstanceForAnalysisId:(NSNumber *)ruleInstanceId forAnalysisId:(NSNumber *)analysisId;

/**
 Returns list of pkg master Ids for given analyses. Details of the packages can be retrieved via the INVProjectManager

 @param analysisId Id for analysis

 @see INVPackage

 @see INVProjectManager

 @return The array of rule Ids
 */
- (NSSet *)pkgMastersForAnalysisId:(NSNumber *)analysisId;

/**
 Returns list of analysesIds for given pkg master. Details of the rules can be retrieved via the fetchRequestForRules

 @param pkgMasterId Id for pkgMaster

 @see INVPackage

 @see fetchRequestForRules

 @return The array of rule sets
 */
- (NSSet *)analysesIdsForPkgMaster:(NSNumber *)pkgMasterId;

@end
