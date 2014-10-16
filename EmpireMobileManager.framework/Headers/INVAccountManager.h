//
//  INVAccountManager.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/1/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

@import Foundation;
@import CoreData;

#import "INVAccount.h"
#import "INVUser.h"
#import "INVSignedInUser.h"
#import "INVSignedInAccount.h"
#import "INVMembership.h"
#import "INVInvite.h"

@interface INVAccountManager : NSObject

/**
 The profile of signed in user
 */
@property (nonatomic,readonly)INVSignedInUser* signedinUser;


/**
 The profile of account into which user has currently signed in
 */
@property (nonatomic,readonly)INVSignedInAccount* signedinAccount;


/**
 The token of signed in user that is result of a succesful login to the XOSPassport server
 */
@property (nonatomic,readonly,copy)NSString* tokenOfSignedInUser;


/**
 The token associated with account into which user has signed in that is the result of a successful log into a specific account
 */
@property (nonatomic,readonly,copy)NSString* tokenOfSignedInAccount;

/**
 The list of INVAccount objects associated with the user following a succesful login to the XOSPassport server
 */
@property (nonatomic,readonly,copy)INVAccountArray accountsOfSignedInUser;

/**
 List of account users
 */
@property (nonatomic,readonly,copy)INVMembersArray accountMembership;


/**
 List of pending invites to account for currently signed in user
 */
@property (nonatomic,readonly,copy)INVInviteArray accountInvitesForUser;

/**
 List of pending invites for account
 */
@property (nonatomic,readonly,copy)INVInviteArray accountInvites;


/**
 The managed object context - Use this in conjunction with the various NSFetchRequests to handle fetching and processing of data
 */
@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;


/**
 Can be used to obtain information on all pending invitations
 */
@property (nonatomic,readonly) NSFetchRequest* fetchRequestForPendingInvitesForAccount;


/**
 Can be used to obtain information on members (and associated accounts).
 */
@property (nonatomic,readonly) NSFetchRequest* fetchRequestForAccountMembership;

/**
 Can be used to obtain information on invitations
 */
@property (nonatomic,readonly) NSFetchRequest* fetchRequestForAccountsOfSignedInUser;




/**
 Creates a singleton instance of INVAccountManager.
 
 @note Instances of INVAccountManager are exclusively created and managed by INVMobileClient. Applications MUST NOT create and manage instances of this class but
 must instead refer to accountManager property of INVEmpireMobileClient
 
 @param managedContext Context for managing data
 
 @see INVMobileClient
 
 @return The singleton instance
 */
+(instancetype)sharedInstanceWithManagedContext:(NSManagedObjectContext*)managedContext;


#warning Include way to asyncronously Notify when deletion is done
/**
 Removes all persisted information pertaining to the signed in user. Although the deletion is initated , a nil error response does not necessarily imply that all data was
 removed as requested.
 

@return  nil if there was no error deleting user data else appropriate error object
*/
-(NSError*)deleteSignedInUserData;



@end
