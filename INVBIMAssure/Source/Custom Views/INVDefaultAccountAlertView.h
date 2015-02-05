//
//  INVDefaultAccountAlertView.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/8/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol INVDefaultAccountAlertViewDelegate<NSObject>

- (void)onAcceptButtonSelectedWithDefault:(BOOL)isDefault;
- (void)onCancelButtonSelected;


@end

@interface INVDefaultAccountAlertView : UIView
@property (nonatomic, weak) id<INVDefaultAccountAlertViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UISwitch *defaultSwitch;
@property (weak, nonatomic) IBOutlet UILabel *alertMessage;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *setAsDefaultContainer;

- (IBAction)setAsDefaultAccountSwitchToggled:(id)sender;
- (IBAction)onAccept:(id)sender;
- (IBAction)onCancel:(id)sender;

@end
