//
//  INVDefaultAccountAlertView.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/8/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol INVDefaultAccountAlertViewDelegate <NSObject>

-(void)onLogintoAccountWithDefault:(BOOL)isDefault;
-(void)onCancelLogintoAccount;

@end

@interface INVDefaultAccountAlertView : UIView
@property (weak, nonatomic) IBOutlet UISwitch *defaultSwitch;
@property (nonatomic,weak)id<INVDefaultAccountAlertViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *alertMessage;


- (IBAction)setAsDefaultAccountSwitchToggled:(id)sender;
- (IBAction)onLogintoAccount:(id)sender;
- (IBAction)onCancelLogin:(id)sender;

@end
