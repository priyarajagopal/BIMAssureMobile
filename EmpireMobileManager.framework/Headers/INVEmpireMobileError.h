//
//  INVEmpireMobileError.h
//  EmpireMobileManager
//
//  Created by Priya Rajagopal on 9/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

@import Foundation;

#import <Mantle/Mantle.h>


// List of supported error codes
typedef NSInteger INV_ERROR_CODE;

static const INV_ERROR_CODE INV_ERROR_CODE_GENERIC = 500;
static const INV_ERROR_CODE INV_ERROR_CODE_AUTHORIZATIONFAILURE = 401;
static const INV_ERROR_CODE INV_ERROR_CODE_RESOURCENOTFOUND = 404;
static const INV_ERROR_CODE INV_ERROR_CODE_INVALIDREQUESTPARAM = 400;
static const INV_ERROR_CODE INV_ERROR_CODE_DUPLICATEUSERINVITE = 1000;
static const INV_ERROR_CODE INV_ERROR_CODE_INVALIDINVITATIONCODE = 1001;

// List of supported error messages
typedef NSString* INV_ERROR_MESG;

static const INV_ERROR_MESG INV_ERROR_MESG_GENERIC_ERROR = @"Error while processing server response";
static const INV_ERROR_MESG  INV_ERROR_MESG_AUTHORIZATIONFAILURE = @"User is not authorized to perform this request";
static const INV_ERROR_MESG  INV_ERROR_MESG_RESOURCENOTFOUNDFAILURE = @"Requested resource could not be found";
static const INV_ERROR_MESG  INV_ERROR_MESG_INVALIDREQUESTFAILURE = @"Request parameters are not valid";
static const INV_ERROR_MESG  INV_ERROR_MESG_DUPLICATEUSERINVITE = @"User has already been invited to the account";
static const INV_ERROR_MESG  INV_ERROR_MESG_INVALIDINVITATIONCODE = @"This is not a valid pending invite";


@interface INVEmpireMobileError : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSString *message;
@property (copy, nonatomic, readonly) NSNumber *code;

@end
