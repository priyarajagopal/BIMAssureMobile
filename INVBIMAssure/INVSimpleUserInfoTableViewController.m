//
//  INVSimpleUserInfoTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/16/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVSimpleUserInfoTableViewController.h"

#pragma mark - KVO

const NSInteger NUM_ROWS = 2;
const NSInteger INDEX_ROW_LOGGEDINUSER = 0;
const NSInteger INDEX_ROW_LOGOUT = 1;

@interface INVSimpleUserInfoTableViewController () 
@property (nonatomic,assign) BOOL accountLogOutSuccess;

@end

@implementation INVSimpleUserInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == INDEX_ROW_LOGOUT) {
        [[NSNotificationCenter defaultCenter]postNotificationName:INV_NotificationLogOutSuccess object:nil];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NUM_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    if (indexPath.row == INDEX_ROW_LOGGEDINUSER) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CurrentUserCell"];
      //  cell = [tableView dequeueReusableCellWithIdentifier:@"CurrentUserCell" forIndexPath:indexPath];
        NSDictionary* savedCredentials = self.globalDataManager.credentials;
        NSString* loggedInUser = savedCredentials[INV_CredentialKeyEmail];
        cell.textLabel.text = loggedInUser;
    }
    if (indexPath.row == INDEX_ROW_LOGOUT) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LogOutCell"];
        cell.textLabel.text = NSLocalizedString(@"LOG_OUT", nil);
        UILabel * accessoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,40,40)];
        accessoryLabel.font = [UIFont fontWithName:@"FontAwesome" size:20];
        accessoryLabel.textColor = [UIColor grayColor];
        accessoryLabel.text = @"\uF08B";
        cell.accessoryView = accessoryLabel;
    //    cell = [tableView dequeueReusableCellWithIdentifier:@"LogOutCell" forIndexPath:indexPath];
    }
    return cell;
}

@end
