//
//  INVModelViewerContainerViewController.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/21/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVModelViewerContainerViewController.h"
#import "INVModelTreeContainerViewController.h"
#import "NSObject+INVCustomizations.h"

#import <QuartzCore/QuartzCore.h>

@interface INVModelViewerContainerViewController ()

@property (nonatomic, strong) INVModelViewerViewController *modelViewController;
@property (nonatomic, strong) INVModelTreeContainerViewController *modelTreeContainerViewController;

@property IBOutlet UIView *modelTreeView;
@property IBOutlet NSLayoutConstraint *collapseModelTreeConstraint;

@end

@implementation INVModelViewerContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[INVModelViewerViewController class]]) {
        self.modelViewController = segue.destinationViewController;

        [self bindKeyPath:@"modelId" toObject:self keyPath:@"modelViewController.modelId"];
        [self bindKeyPath:@"fileVersionId" toObject:self keyPath:@"modelViewController.fileVersionId"];
    }

    if ([[segue destinationViewController] isKindOfClass:[INVModelTreeContainerViewController class]]) {
        self.modelTreeContainerViewController = segue.destinationViewController;

        [self bindKeyPath:@"fileVersionId" toObject:self keyPath:@"modelTreeContainerViewController.packageVersionId"];
        [self bindKeyPath:@"packageMasterId" toObject:self keyPath:@"modelTreeContainerViewController.packageMasterId"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)toggleSidebar:(id)sender
{
    if ([[self.modelTreeView constraints] containsObject:self.collapseModelTreeConstraint]) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.modelTreeView.alpha = 1;

                             [self.modelTreeView removeConstraint:self.collapseModelTreeConstraint];
                             [self.modelTreeView layoutIfNeeded];
                         }];
    }
    else {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.modelTreeView.alpha = 0;

                             [self.modelTreeView addConstraint:self.collapseModelTreeConstraint];
                             [self.modelTreeView layoutIfNeeded];
                         }];
    }
}

- (IBAction)goHome:(id)sender
{
    [self.modelViewController goHome:sender];
}

- (IBAction)toggleShadow:(id)sender
{
    [self.modelViewController toggleShadow:sender];
}

- (IBAction)toggleGlass:(id)sender
{
    [self.modelViewController toggleGlass:sender];
}

- (IBAction)toggleVisible:(id)sender
{
    [self.modelViewController toggleVisible:sender];
}

- (void)highlightElement:(NSString *)elementId
{
    [self.modelViewController highlightElement:elementId];
}

@end
