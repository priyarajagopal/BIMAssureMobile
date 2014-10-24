//
//  INVInviteUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/24/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVInviteUsersTableViewController.h"
#import "INVTextViewTableViewCell.h"


static const NSInteger DEFAULT_MESSAGE_CELL_HEIGHT = 200;
static const NSInteger DEFAULT_INVITEDUSERS_CELL_HEIGHT = 50;
static const NSInteger DEFAULT_NUM_ROWS_SECTION = 1;
static const NSInteger DEFAULT_NUM_SECTIONS = 2;
static const NSInteger SECTIONINDEX_INVITEUSERLIST = 0;
static const NSInteger SECTIONINDEX_MESSAGE = 1;
static const NSInteger DEFAULT_HEADER_HEIGHT = 40;


@interface INVInviteUsersTableViewController () <INVTextViewTableViewCellDelegate>
@property (nonatomic,strong)INVAccountManager* accountManager;
@property (nonatomic,assign)NSInteger messageRowHeight;

@end

@implementation INVInviteUsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"INVITE_USERS", nil);
    
    self.accountManager = self.globalDataManager.invServerClient.accountManager;
    
    self.messageRowHeight = DEFAULT_MESSAGE_CELL_HEIGHT;
    
    UINib* nib = [UINib nibWithNibName:@"INVTextViewTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MessageTextCell"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return DEFAULT_NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DEFAULT_NUM_ROWS_SECTION;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SECTIONINDEX_INVITEUSERLIST) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteUserCell" ];
        return  cell;
    }
    if (indexPath.section == SECTIONINDEX_MESSAGE) {
        INVTextViewTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MessageTextCell" ];
        cell.cellDelegate = self;
        
        return cell;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTIONINDEX_MESSAGE) {
        return [NSLocalizedString(@"ENTER_OPTIONAL_MESSAGE", nil)lowercaseStringWithLocale:[NSLocale currentLocale]];
    }
    if (section == SECTIONINDEX_INVITEUSERLIST) {
        return [NSLocalizedString(@"ENTER_INVITED_USERS", nil)lowercaseStringWithLocale:[NSLocale currentLocale]];
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return DEFAULT_HEADER_HEIGHT;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = 0;
    if (indexPath.section == SECTIONINDEX_MESSAGE)
    {
        return self.messageRowHeight;
    }
    else if (indexPath.section == SECTIONINDEX_INVITEUSERLIST)
    {
        return DEFAULT_INVITEDUSERS_CELL_HEIGHT;
    }
    
    return height;
}


#pragma mark - INVTextViewTableViewCellDelegate
-(void)cellSizeChanged:(CGSize)size withTextString:(NSString*)textStr {
    NSLog(@"%s",__func__);
    [self.tableView beginUpdates];
    self.messageRowHeight = size.height;
    [self.tableView endUpdates];
}


@end
