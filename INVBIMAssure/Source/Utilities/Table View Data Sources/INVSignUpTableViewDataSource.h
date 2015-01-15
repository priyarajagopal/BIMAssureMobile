//
//  INVSignUpTableViewDataSource.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 1/15/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    _INVSignUpTableSectionType_UserDetails = 0,
    _INVSignUpTableSectionType_ToggleSwitch = 1,
    _INVSignUpTableSectionType_Account = 2
}_INVSignUpTableSectionType;

typedef enum {
    _INVSignUpTableRowType_UserName = 0,
    _INVSignUpTableRowType_Email,
    _INVSignUpTableRowType_Password ,
    _INVSignUpTableRowType_ToggleSwitch ,
    _INVSignUpTableRowType_AccountName ,
    _INVSignUpTableRowType_AccountDesc,
    _INVSignUpTableRowType_Subscription
    
}_INVSignUpTableRowType;


@interface INVSignUpTableViewDataSource : NSObject
-(instancetype) initWithSignUpSetting:(BOOL)shouldSignUpUser;
-(NSInteger) numSections ;
-(NSInteger) indexOfSection:(_INVSignUpTableSectionType) type;
-(_INVSignUpTableSectionType) typeOfSectionAtIndex: (NSInteger)index;
-(NSInteger) heightOfRowAtIndex:(NSInteger)rowIndex forSectionType: ( _INVSignUpTableSectionType) sectionType withInvitationCodeSet:(BOOL) setInvitationCode;
-(NSInteger) numRowsForSectionType:(_INVSignUpTableSectionType) sectionType  withInvitationCodeSet:(BOOL) setInvitationCode ;

@end
