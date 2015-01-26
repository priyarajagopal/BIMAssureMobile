//
//  INVModalPresentationFromParentSegue.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/26/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModalPresentationFromParentSegue.h"

@implementation INVModalPresentationFromParentSegue

-(void) perform {
    UIViewController *source = self.sourceViewController;
    UIViewController *dest = self.destinationViewController;
    
    source = source.presentingViewController;
    
    [source dismissViewControllerAnimated:YES completion:^{
        [source presentViewController:dest animated:YES completion:nil];
    }];
}

@end
