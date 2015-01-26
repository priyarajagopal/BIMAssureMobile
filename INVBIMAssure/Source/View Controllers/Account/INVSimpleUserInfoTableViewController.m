//
//  INVSimpleUserInfoTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/16/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVSimpleUserInfoTableViewController.h"

#pragma mark - KVO

const NSInteger INDEX_ROW_CHANGE_PASSWORD = 0;
const NSInteger INDEX_ROW_LOGOUT = 1;

@interface INVSimpleUserInfoTableViewController () 
@property (nonatomic,assign) BOOL accountLogOutSuccess;

@end

@implementation INVSimpleUserInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor* cyanColor = [UIColor colorWithRed:194.0/255 green:224.0/255 blue:240.0/255 alpha:1.0];
    
    self.tableView.backgroundColor = cyanColor;
    self.refreshControl = nil;
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == INDEX_ROW_LOGOUT) {
        [self.globalDataManager performLogout];
    }
}

#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* loggedInUser = self.globalDataManager.loggedInUser;
    return loggedInUser;
}

@end
