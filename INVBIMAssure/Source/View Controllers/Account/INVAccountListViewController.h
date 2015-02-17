//
//  INVAccountListViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - KVO
extern NSString *const KVO_INVAccountLoginSuccess;

@interface INVAccountListViewController : INVCustomCollectionViewController

@property (nonatomic, assign) BOOL autoSignIntoDefaultAccount;
@property (nonatomic, readonly) BOOL accountLoginSuccess;
@property (nonatomic, assign) BOOL hideSettingsButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *settingsButton;

- (IBAction)selectThumbnail:(id)sender;

@end
