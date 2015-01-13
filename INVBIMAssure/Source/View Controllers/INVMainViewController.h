//
//  INVMainViewController.h
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/14/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVCustomViewController.h"

@interface INVMainViewController : INVCustomViewController
@property (weak, nonatomic) IBOutlet UIView *detailContainerView;
@property (weak, nonatomic) IBOutlet UIView *mainMenuContainerView;
-(IBAction)done:(UIStoryboardSegue*)segue;
@end
