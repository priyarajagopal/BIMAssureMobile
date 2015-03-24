//
//  INVThirdPartySoftware.m
//  INVBIMAssure
//
//  Created by Richard Ross on 3/24/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVThirdPartySoftwareViewController.h"

@interface INVThirdPartySoftwareViewController () <UIWebViewDelegate>

@property IBOutlet UIWebView *licenseWebView;

@end

@implementation INVThirdPartySoftwareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *licensePath = [[NSBundle mainBundle] pathForResource:@"Licensing" ofType:@"html"];
    [self.licenseWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:licensePath]]];
}

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked && ![[request URL] isFileURL]) {
        [[UIApplication sharedApplication] openURL:[request URL]];

        return NO;
    }

    return YES;
}

@end
