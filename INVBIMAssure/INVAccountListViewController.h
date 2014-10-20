//
//  INVAccountListViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - KVO
extern NSString* const KVO_INVAccountLoginSuccess ;

@interface INVAccountListViewController : INVCustomCollectionViewController

@property (nonatomic,readonly) BOOL accountLoginSuccess;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

- (IBAction)onDoneTapped:(id)sender;
@end
