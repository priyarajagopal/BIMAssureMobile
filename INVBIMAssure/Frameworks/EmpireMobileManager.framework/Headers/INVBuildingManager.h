//
//  INVBuildingManager.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/17/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//  //////////////////// DO NOT USE THIS CLASS> SERVER SIDE UNTESTED AND SUBJECT TO CHANGE >>>>>>>>>>>>

@import Foundation;
@import CoreData;

#import "INVBuildingElement.h"

@interface INVBuildingManager : NSObject

/**
 The managed object context - Use this in conjunction with the various NSFetchRequests to handle fetching and processing of data
 */
@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;


/**
 Creates a singleton instance of INVBuildingManager.
 
 @note Instances of INVBuildingManager are exclusively created and managed by INVMobileClient. Applications MUST NOT create and manage instances of this class but
 instance refer to buildingManager property of INVEmpireMobileClient
 
 @param managedContext Context for managing data
 
 @see INVMobileClient
 
 @return The singleton instance
 */
+(instancetype)sharedInstanceWithManagedContext:(NSManagedObjectContext*)managedContext;

/**
 Returns building element details for element with specified Id
 
 @param elementId elementId for which building elements are to be fetched
 
 @see INVBuildingElement
 
 @return The INVBuildingElement
 */
-(INVBuildingElement*) buildingElementForID:(NSNumber*)elementId;

#warning Include way to asyncronously Notify when deletion is done

/**
 Removes all persisted building element information. Although the deletion is initated , a nil error response does not necessarily imply that all data was
 removed as requested.
 @return  nil if there was no error deleting user data else appropriate error object.
 */
-(NSError*)removeAllBuildingElementsCachedData;



@end
