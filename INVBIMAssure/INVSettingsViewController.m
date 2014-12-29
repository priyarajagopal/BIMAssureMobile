//
//  INVSettingsViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 12/29/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVSettingsViewController.h"
@import CoreFoundation;

static const NSInteger HEADER_HEIGHT = 50;

@implementation INVSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"SETTINGS", nil);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupTableHeader];
}


-(void) setupTableHeader {
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth (self.tableView.frame), HEADER_HEIGHT)];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [label setTextAlignment:NSTextAlignmentCenter];
    NSDictionary* infoDict = [NSBundle bundleForClass:[self class]].infoDictionary;
    NSString* build = infoDict[(NSString*)kCFBundleVersionKey];
    NSString* version = infoDict[@"CFBundleShortVersionString"];

    
    label.text = [NSString stringWithFormat: NSLocalizedString(@"APP_VERSION", nil) ,version,build];
     self.tableView.tableHeaderView = label;
}
@end
