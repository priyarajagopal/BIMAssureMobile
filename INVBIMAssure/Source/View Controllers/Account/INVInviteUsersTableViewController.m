//
//  INVInviteUsersTableViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/24/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVInviteUsersTableViewController.h"
#import "INVTextViewTableViewCell.h"
#import "INVTokensTableViewCell.h"

static const NSInteger DEFAULT_MESSAGE_CELL_HEIGHT = 200;
static const NSInteger DEFAULT_INVITEDUSERS_CELL_HEIGHT = 100;
static const NSInteger DEFAULT_NUM_ROWS_SECTION = 1;
static const NSInteger DEFAULT_NUM_SECTIONS = 2;
static const NSInteger SECTIONINDEX_INVITEUSERLIST = 0;
static const NSInteger SECTIONINDEX_MESSAGE = 1;
static const NSInteger DEFAULT_HEADER_HEIGHT = 40;


@interface INVInviteUsersTableViewController () <INVTextViewTableViewCellDelegate,INVTokensTableViewCellDelegate>
@property (nonatomic,strong)INVAccountManager* accountManager;
@property (nonatomic,assign)NSInteger messageRowHeight;
@property (nonatomic,weak)INVTokensTableViewCell* inviteUsersCell;
@property (nonatomic,copy)NSArray* tokens;
@end

@implementation INVInviteUsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"INVITE_USERS", nil);
    
    self.refreshControl = nil;
    self.messageRowHeight = DEFAULT_MESSAGE_CELL_HEIGHT;
    
    UINib* nib = [UINib nibWithNibName:@"INVTextViewTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MessageTextCell"];
    
    UINib* inviteNib = [UINib nibWithNibName:@"INVTokensTableViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.tableView registerNib:inviteNib forCellReuseIdentifier:@"InviteUserCell"];
    
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tokens = nil;
    self.accountManager = nil;
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
        INVTokensTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteUserCell" ];
        CGRect currFrame = cell.tokenField.frame;
        currFrame.size.width = tableView.frame.size.width;
        cell.tokenField.frame = currFrame;
        cell.cellDelegate = self;
        self.inviteUsersCell = cell;
        return  cell;
    }
    if (indexPath.section == SECTIONINDEX_MESSAGE) {
        INVTextViewTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MessageTextCell" ];
        cell.cellDelegate = self;
        
        return cell;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return DEFAULT_HEADER_HEIGHT;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.text = [tableViewHeaderFooterView.textLabel.text lowercaseStringWithLocale:[NSLocale currentLocale]];
    }
}

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTIONINDEX_MESSAGE) {
        return NSLocalizedString(@"ENTER_OPTIONAL_MESSAGE", nil);
    }
    if (section == SECTIONINDEX_INVITEUSERLIST) {
        return NSLocalizedString(@"ENTER_INVITED_USERS", nil);
    }
    
    return nil;
}


#pragma mark - INVTextViewTableViewCellDelegate
-(void)cellSizeChanged:(CGSize)size withTextString:(NSString*)textStr {
     [self.tableView beginUpdates];
    self.messageRowHeight = size.height;
    [self.tableView endUpdates];
}

#pragma mark - INVTokensTableViewCellDelegate
-(void)tokensChanged:(NSArray*)inputTokens {
    self.tokens = inputTokens;
    if (self.tokens.count) {
        [self.sendButton setEnabled:YES];
    }
    else {
        [self.sendButton setEnabled:NO];
    }
    
}
#pragma mark - UIEvent Handlers
- (IBAction)onSendClicked:(id)sender {
    self.hud = [MBProgressHUD generalViewHUD:NSLocalizedString(@"INVITING", nil)];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    [self inviteUsers:[self cleanupTokens:self.tokens] withMessage:@""];

}


#pragma mark - server side
-(void)inviteUsers:(NSArray*)users withMessage:(NSString*)message {
#warning Message not supported by API for now
    [self.globalDataManager.invServerClient inviteUsersToSignedInAccount:users withCompletionBlock:^(INVEmpireMobileError *error) {
         [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        if (error) {
            [self showInviteFailureAlert];
            
        }
        else {
            
            [self performSegueWithIdentifier:@"ReturnToUserManagementSegue" sender:self];
        }
    }];
}

#pragma mark - accessors
-(INVAccountManager*)accountManager {
    if (!_accountManager) {
        _accountManager = self.globalDataManager.invServerClient.accountManager;
    }
    return _accountManager;
}


#pragma mark - helpers
-(NSArray*)cleanupTokens:(NSArray*)tokens {
    NSMutableArray* cleanTokens = [[NSMutableArray alloc]initWithCapacity:0];
    [tokens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* token = obj;
        token = [token stringByReplacingOccurrencesOfString:@"," withString:@""];
        [cleanTokens addObject:token];
    }];
    return cleanTokens;
    
}
-(void)showInviteFailureAlert {
    UIAlertController* inviteFailureAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INVITE_FAILURE", nil) message:NSLocalizedString(@"GENERIC_INVITE_FAILURE_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [inviteFailureAlertController dismissViewControllerAnimated:YES completion:nil];
    }];

    [inviteFailureAlertController addAction:action];
    [self presentViewController:inviteFailureAlertController animated:YES completion:^{
        
    }];
}


@end
