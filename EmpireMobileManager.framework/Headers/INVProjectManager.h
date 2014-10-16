//
//  INVProjectManager.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/2/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//


@import Foundation;
@import CoreData;

#import "INVFile.h"
#import "INVProject.h"

@interface INVProjectManager : NSObject

/**
 The managed object context - Use this in conjunction with the various NSFetchRequests to handle fetching and processing of data
 */
@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;


/**
 Can be used to obtain information on projects associated with an account
 */
@property (nonatomic,readonly) NSFetchRequest* fetchRequestForProjects;


/**
 Can be used to directly fetch information on project files
 */
@property (nonatomic,readonly) NSFetchRequest* fetchRequestForProjectFiles;


/**
 List of projects
 */
@property (nonatomic,readonly,copy)INVProjectArray projectsInAccount;

/**
 List of project files
 */
@property (nonatomic,readonly,copy)INVFileArray projectFiles;

/**
 Creates a singleton instance of INVProjectManager.
 
 @note Instances of INVProjectManager are exclusively created and managed by INVMobileClient. Applications MUST NOT create and manage instances of this class but
 instance refer to projectManager property of INVEmpireMobileClient
 
 @param managedContext Context for managing data
 
 @see INVMobileClient
 
 @return The singleton instance
 */
+(instancetype)sharedInstanceWithManagedContext:(NSManagedObjectContext*)managedContext;

#warning Include way to asyncronously Notify when deletion is done
/**
 Removes all persisted information pertaining to the signed in user. Although the deletion is initated , a nil error response does not necessarily imply that all data was
 removed as requested.
 @return  nil if there was no error deleting user data else appropriate error object.
 */
-(NSError*)deleteProjectData;

@end