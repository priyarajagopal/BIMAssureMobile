//
//  INVProjectManager.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/2/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

//@import Foundation;
//@import CoreData;

#import "INVPackage.h"
#import "INVProject.h"

@interface INVProjectManager : NSObject

/**
 The managed object context - Use this in conjunction with the various NSFetchRequests to handle fetching and processing of data
 */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 Can be used to obtain information on projects associated with an account
 */
@property (nonatomic, readonly, copy) NSFetchRequest *fetchRequestForProjects;

/**
 Can be used to directly fetch information on project files
 */
@property (nonatomic, readonly, copy) NSFetchRequest *fetchRequestForPackages;

/**
 List of projects
 */
@property (nonatomic, readonly, copy) INVProjectArray projectsInAccount;

/**
 Creates a singleton instance of INVProjectManager.

 @note Instances of INVProjectManager are exclusively created and managed by INVMobileClient. Applications MUST NOT create and
 manage instances of this class but
 instance refer to projectManager property of INVEmpireMobileClient

 @param managedContext Context for managing data

 @see INVMobileClient

 @return The singleton instance
 */
+ (instancetype)sharedInstanceWithManagedContext:(NSManagedObjectContext *)managedContext;

/**
 Returns project files associated with file masterIds

 @see INVMobileClient

 @return The array of INVPackage objects corresponding to the list of master Ids
 */
- (INVPackageArray)packageFilesForMasterIds:(NSArray *)fileMasterIds;

/**
 Returns project packages for specified project Id

 @see INVMobileClient

 @return The array of INVPackage objects corresponding to the list of master Ids
 */
- (INVPackageArray)packagesForProjectId:(NSNumber *)projectId;


@end