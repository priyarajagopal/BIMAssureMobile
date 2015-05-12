//
//  INVInvite.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 10/15/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "INVInviteContext.h"
/*
{
    "totalcount": 0,
    "pagesize": 1000,
    "list": [
    {
        "accountname": "Demo Account",
        "inviteremail": "priya.rajagopal@invicara.com",
        "createdby": 4,
        "code": "UHAF6xz4dknEtuYk3PYuTr6mQnvVTuJ2",
        "createdat": 1431393075000,
        "updatedat": 1431393075000,
        "id": 8,
        "expires": 1431997874000,
        "updatedby": 4,
        "email": "foobar@yahoo.com",
        "roles": [
                  1
                  ],
        "inviterid": 4,
        "context": {
            "projects": [ ]
        },
        "accountid": 5
    }
             ],
    "includetotal": false,
    "offset": 0
}
 */
/**
 Array of INVInvite objects
 */
typedef NSArray *INVInviteArray;

/**
 Mutable array of INVInvite objects
 */
typedef NSMutableArray *INVInviteMutableArray;

@interface INVInvite : MTLModel<MTLJSONSerializing, MTLManagedObjectSerializing>
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSNumber *createdBy;
@property (copy, nonatomic, readonly) NSDate *updatedAt;
@property (copy, nonatomic, readonly) NSNumber *updatedBy;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *invitationCode;
@property (copy, nonatomic, readonly) NSNumber *invitationId;
@property (copy, nonatomic, readonly) NSArray *roles;
@property (copy, nonatomic, readonly) INVInviteContext* context;
@end
