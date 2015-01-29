//
//  INVSignUpTableViewDataSource.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVSignUpTableViewConfigDataSource.h"

// Configuration of table
const NSInteger CELL_HEIGHT_DEFAULT = 50;
const NSInteger CELL_HEIGHT_SUBSCRIPTION = 207;
const NSInteger CELL_HEIGHT_ACCOUNTDESC = 100;

const NSInteger NUM_SECTIONS_USERSIGNUP = 3;
const NSInteger NUM_SECTIONS_NOUSERSIGNUP = 1;

const NSInteger NUM_ROWS_USERDETAILS = 3;
const NSInteger NUM_ROWS_TOGGLESWITCH = 1;
const NSInteger NUM_ROWS_ACCOUNT_INVITATIONCODE = 1;
const NSInteger NUM_ROWS_ACCOUNT_NOINVITATIONCODE = 3;

const NSInteger SECTIONINDEX_USERDETAILS = 0;          // user details
const NSInteger SECTIONINDEX_TOGGLESWITCH = 1;         // toggle
const NSInteger SECTIONINDEX_ACCOUNT_NOUSERSIGNUP = 0; // subscription info or invitation code as appropriate
const NSInteger SECTIONINDEX_ACCOUNT_USERSIGNUP = 2;   // subscription info or invitation code as appropriate

const NSInteger CELLINDEX_USERNAME = 0;
const NSInteger CELLINDEX_EMAIL = 1;
const NSInteger CELLINDEX_PASSWORD = 2;

const NSInteger CELLINDEX_TOGGLE = 0;
const NSInteger CELLINDEX_ACCOUNTNAME = 0;
const NSInteger CELLINDEX_ACCOUNTDESCRIPTION = 1;
const NSInteger CELLINDEX_SUBSCRIPTIONTYPE = 2;
const NSInteger CELLINDEX_INVITATIONCODE = 0;

@interface INVSignUpTableViewConfigDataSource ()
@property (nonatomic, assign) BOOL shouldSignUpUser;
@end

@implementation INVSignUpTableViewConfigDataSource
- (instancetype)initWithSignUpSetting:(BOOL)shouldSignUpUser
{
    self = [super init];
    if (self) {
        self.shouldSignUpUser = shouldSignUpUser;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithSignUpSetting:NO];
}

#pragma public methods
- (NSInteger)estimatedRowHeight
{
    return CELL_HEIGHT_DEFAULT;
}

- (NSInteger)numSections
{
    if (self.shouldSignUpUser) {
        return NUM_SECTIONS_USERSIGNUP;
    }
    else {
        return NUM_SECTIONS_NOUSERSIGNUP;
    }
}

- (NSInteger)indexOfSection:(_INVSignUpTableSectionType)type
{
    switch (type) {
        case _INVSignUpTableSectionType_UserDetails:
            if (self.shouldSignUpUser) {
                return SECTIONINDEX_USERDETAILS;
            }
            else {
                return NSNotFound;
            }
        case _INVSignUpTableSectionType_ToggleSwitch:
            if (self.shouldSignUpUser) {
                if (self.shouldSignUpUser) {
                    return SECTIONINDEX_TOGGLESWITCH;
                }
                else {
                    return NSNotFound;
                }
            }
        case _INVSignUpTableSectionType_Account:
            if (self.shouldSignUpUser) {
                return SECTIONINDEX_ACCOUNT_USERSIGNUP;
            }
            else {
                return SECTIONINDEX_ACCOUNT_NOUSERSIGNUP;
            }
        default:
            return NSNotFound;
    }
}

- (_INVSignUpTableSectionType)typeOfSectionAtIndex:(NSInteger)index
{
    if (self.shouldSignUpUser) {
        switch (index) {
            case SECTIONINDEX_USERDETAILS:
                return _INVSignUpTableSectionType_UserDetails;
            case SECTIONINDEX_TOGGLESWITCH:
                return _INVSignUpTableSectionType_ToggleSwitch;
            case SECTIONINDEX_ACCOUNT_USERSIGNUP:
                return _INVSignUpTableSectionType_Account;
        }
    }
    return _INVSignUpTableSectionType_Account;
}

- (_INVSignUpTableRowType)typeOfRowForSection:(_INVSignUpTableSectionType)section AtIndex:(NSInteger)row
{
    switch (section) {
        case _INVSignUpTableSectionType_UserDetails:
            if (row == CELLINDEX_USERNAME) {
                return _INVSignUpTableRowType_UserName;
            }
            else if (row == CELLINDEX_PASSWORD) {
                return _INVSignUpTableRowType_Password;
            }
            else if (row == CELLINDEX_EMAIL) {
                return _INVSignUpTableRowType_Email;
            }
            break;
        case _INVSignUpTableSectionType_ToggleSwitch:
            return _INVSignUpTableRowType_Subscription;
            break;
        case _INVSignUpTableSectionType_Account:
            if (row == CELLINDEX_ACCOUNTNAME) {
                return _INVSignUpTableRowType_AccountName;
            }
            if (row == CELLINDEX_ACCOUNTDESCRIPTION) {
                return _INVSignUpTableRowType_AccountDesc;
            }
            if (row == CELLINDEX_SUBSCRIPTIONTYPE) {
                return _INVSignUpTableRowType_Subscription;
            }

            break;
    }
    return _INVSignUpTableRowType_Email;
}

- (NSInteger)heightOfRowAtIndex:(NSInteger)rowIndex
                 forSectionType:(_INVSignUpTableSectionType)sectionType
          withInvitationCodeSet:(BOOL)setInvitationCode
{
    if (!setInvitationCode && sectionType == _INVSignUpTableSectionType_Account) {
        if (rowIndex == CELLINDEX_SUBSCRIPTIONTYPE) {
            return CELL_HEIGHT_SUBSCRIPTION;
        }
        else if (rowIndex == CELLINDEX_ACCOUNTDESCRIPTION) {
            return CELL_HEIGHT_ACCOUNTDESC;
        }
    }
    return CELL_HEIGHT_DEFAULT;
}

- (NSInteger)numRowsForSectionType:(_INVSignUpTableSectionType)sectionType withInvitationCodeSet:(BOOL)setInvitationCode
{
    switch (sectionType) {
        case _INVSignUpTableSectionType_UserDetails:
            return NUM_ROWS_USERDETAILS;
        case _INVSignUpTableSectionType_ToggleSwitch:
            return NUM_ROWS_TOGGLESWITCH;
        case _INVSignUpTableSectionType_Account:
            if (setInvitationCode) {
                return NUM_ROWS_ACCOUNT_INVITATIONCODE;
            }
            else {
                return NUM_ROWS_ACCOUNT_NOINVITATIONCODE;
            }

        default:
            return 0;
            break;
    }
}

@end
