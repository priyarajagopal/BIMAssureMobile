//
//  TransitionToStoryboard.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/14/15.
//  Copyright (c) 2015
//

#import "INVTransitionToStoryboard.h"

UIStoryboardSegue *segueWithBlock(NSString *identifier, id source, id dst, void (^aBlock)(UIStoryboardSegue *theSegue)) {
    aBlock = [aBlock copy];
    __block __weak UIStoryboardSegue *segue;
    
    id results = [UIStoryboardSegue segueWithIdentifier:identifier source:source destination:dst performHandler:^{
        if (aBlock) {
            aBlock(segue);
        }
    }];
                  
    segue = results;
    return results;
}

@implementation INVTransitionToStoryboard

-(UIStoryboardSegue *) _createSegueWithDestination:(id) destination {
    switch (self.transitionType) {
        case StoryboardTransitionShow:
            return segueWithBlock(self.identifier, self.sourceViewController, destination, ^(UIStoryboardSegue *segue) {
                [segue.sourceViewController showViewController:segue.destinationViewController sender:segue];
            });
            
        case StoryboardTransitionShowDetail:
            return segueWithBlock(self.identifier, self.sourceViewController, destination, ^(UIStoryboardSegue *segue) {
                [segue.sourceViewController showDetailViewController:segue.destinationViewController sender:segue];
            });
            
        case StoryboardTransitionModal:
            return segueWithBlock(self.identifier, self.sourceViewController, destination, ^(UIStoryboardSegue *segue) {
                UIViewController *src = [segue sourceViewController];
                UIViewController *dst = [segue destinationViewController];
                
                if (self.modalPresentationStyle) {
                    dst.modalPresentationStyle = self.modalPresentationStyle;
                }
                
                if (self.modalTransitionStyle) {
                    dst.modalTransitionStyle = self.modalTransitionStyle;
                }
                
                [src presentViewController:dst animated:YES completion:nil];
            });
            
        case StoryboardTransitionPopover:
            return segueWithBlock(self.identifier, self.sourceViewController, destination, ^(UIStoryboardSegue *segue) {
                UIViewController *src = [segue sourceViewController];
                UIViewController *dst = [segue destinationViewController];
                
                dst.modalPresentationStyle = UIModalPresentationPopover;
                [src presentViewController:dst animated:YES completion:nil];
                
                dst.popoverPresentationController.passthroughViews = self.passthroughViews;
                dst.popoverPresentationController.permittedArrowDirections = self.arrowDirection;
                dst.popoverPresentationController.sourceView = self.arrowAnchor;
            });
            
        case StoryboardTransitionCustom: {
            Class segueClass = NSClassFromString(self.customSegueClass);
            return [[segueClass alloc] initWithIdentifier:self.identifier source:self.sourceViewController destination:destination];
        }
    }
    
    return nil;
}

-(void) perform:(id)sender {
    if (![self.sourceViewController shouldPerformSegueWithIdentifier:self.identifier sender:sender]) {
        return;
    }
    
    UIStoryboard *destinationStoryboard = [UIStoryboard storyboardWithName:self.targetStoryboard bundle:[NSBundle bundleForClass:[self class]]];
    UIViewController *destinationViewController = nil;
    
    if (self.targetIdentifier) {
        destinationViewController = [destinationStoryboard instantiateViewControllerWithIdentifier:self.targetIdentifier];
    } else {
        destinationViewController = [destinationStoryboard instantiateInitialViewController];
    }
    
    UIStoryboardSegue *segue = [self _createSegueWithDestination:destinationViewController];
    [self.sourceViewController prepareForSegue:segue sender:sender];
    
    [segue perform];
}

@end
