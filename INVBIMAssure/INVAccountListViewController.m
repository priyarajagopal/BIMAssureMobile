//
//  INVAccountListViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/7/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

@import CoreData;

const NSInteger INV_CELLSIZE = 100;

#import "INVAccountListViewController.h"
#import "INVAccountViewCell.h"
#import "INVDefaultAccountAlertView.h"
#import "INVSimpleUserInfoTableViewController.h"

#pragma mark - KVO
NSString* const KVO_INVAccountLoginSuccess = @"accountLoginSuccess";


@interface INVAccountListViewController () <INVDefaultAccountAlertViewDelegate,UICollectionViewDataSource>
@property (nonatomic,assign) BOOL accountLoginSuccess;
@property (nonatomic,strong) INVDefaultAccountAlertView* alertView ;
@property (nonatomic,strong)INVAccountManager* accountManager;
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)NSNumber* currentAccountId;
@property (nonatomic,strong)UIAlertController* loginFailureAlertController;
@property (nonatomic,strong)UIAlertController* logoutPromptAlertController;
@property (nonatomic,assign)BOOL saveAsDefault;
@property (nonatomic,strong)INVGenericCollectionViewDataSource* dataSource;
@end

@implementation INVAccountListViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = NSLocalizedString(@"ACCOUNTS", nil);
      
    // Register cell classes
    UINib* accountCellNib = [UINib nibWithNibName:@"INVAccountViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.collectionView registerNib:accountCellNib forCellWithReuseIdentifier:@"AccountCell"];
    UIBarButtonItem* settingsButton = self.navigationItem.rightBarButtonItem;
    
    FAKFontAwesome *settingsIcon = [FAKFontAwesome gearIconWithSize:30];
    [settingsButton setImage:[settingsIcon imageWithSize:CGSizeMake(30, 30)]];
 
    [self setEstimatedSizeForCells];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.collectionView.dataSource = self.dataSource;
    
    [self fetchListOfAccounts];

    NSNumber* defaultAcnt = self.globalDataManager.defaultAccountId;
    if (defaultAcnt && self.autoSignIntoDefaultAccount) {
        self.globalDataManager.loggedInAccount = defaultAcnt;
        self.currentAccountId = defaultAcnt;
        [self showLoginProgress];
        [self loginAccount];
    }
    else {
        self.currentAccountId = nil;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.alertView = nil;
    self.accountManager = nil;
    self.dataResultsController = nil;
    self.loginFailureAlertController = nil;
    self.logoutPromptAlertController = nil;
    self.collectionView.dataSource = nil;
    self.dataSource = nil;
}



-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setEstimatedSizeForCells];
}

-(INVGenericCollectionViewDataSource*)dataSource {
    if (!_dataSource) {
        _dataSource = [[INVGenericCollectionViewDataSource alloc]initWithFetchedResultsController:self.dataResultsController];
        INV_CollectionCellConfigurationBlock cellConfigurationBlock = ^(INVAccountViewCell *cell,INVAccount* account ,NSIndexPath* indexPath){
            cell.name.text = account.name;
            cell.overview.text = account.overview;
            NSNumber* currentAcnt = self.globalDataManager.loggedInAccount;
            if (currentAcnt && [account.accountId isEqualToNumber:currentAcnt]) {
                cell.isDefault = YES;
            }
            else {
                cell.isDefault = NO;
            }
            
        };
        [_dataSource registerCellWithIdentifierForAllIndexPaths:@"AccountCell" configureBlock:cellConfigurationBlock];
    }
    return _dataSource;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    /*
    if ([segue.identifier isEqualToString:@"ShowUserInfoSegue"]) {
        INVSimpleUserInfoTableViewController* userVC = segue.destinationViewController;
        userVC.tableView.delegate = userVC;
        userVC.tableView.dataSource = userVC;
    }
    */
}




- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView reloadData];
}


#pragma mark UICollectionViewDelegate

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}



// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog (@"%s",__func__);
    INVAccount* account = [self.dataResultsController objectAtIndexPath:indexPath];
    if ( self.globalDataManager.loggedInAccount == account.accountId) {
        [self showLogoutPromptAlertForAccount:account];
    }
    else {
        self.currentAccountId = account.accountId;
        // [self showBlurEffect];
        if (!self.globalDataManager.loggedInAccount ) {
            NSString* message = [NSString stringWithFormat:NSLocalizedString(@"ARE_YOU_SURE_ACCOUNTLOGIN_MESSAGE",nil),account.name];
            [self showSaveAsDefaultAlertWithMessage:message];
        }
        else {
            NSString* message = [NSString stringWithFormat:NSLocalizedString(@"ARE_YOU_SURE_ACCOUNTSWITCH_MESSAGE",nil),account.name];
            [self showSaveAsDefaultAlertWithMessage:message];
        }
    }
}

/*

// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


#pragma mark - INVDefaultAccountAlertViewDelegate
-(void)onLogintoAccountWithDefault:(BOOL)isDefault {
    [self dismissSaveAsDefaultAlert];
    self.saveAsDefault = isDefault;
    
    NSNumber* prevLoggedInAccount =  self.globalDataManager.loggedInAccount ;
    if (prevLoggedInAccount && (prevLoggedInAccount != self.currentAccountId))
    {
        [self showLoginProgress];
        [self switchToSelectedAccount];
    }
    else {
        [self showLoginProgress];
        [self loginAccount];
    }
}

-(void)onCancelLogintoAccount {
    [self dismissSaveAsDefaultAlert];
}

#pragma mark - accessor
-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.accountManager.fetchRequestForAccountsOfSignedInUser managedObjectContext:self.accountManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    return  _dataResultsController;
}

-(INVAccountManager*)accountManager {
    if (!_accountManager) {
        _accountManager = self.globalDataManager.invServerClient.accountManager;
    }
    return _accountManager;
}

#pragma mark - server side 
-(void)fetchListOfAccounts {
    [self showLoadProgress];
    [self.globalDataManager.invServerClient getAllAccountsForSignedInUserWithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
        
        if (!error) {
      
#pragma note Yes - you could have directly accessed accounts from accountManager. Using FetchResultsController directly makes it simpler
             NSError* dbError;
            
           
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                NSLog(@"%s. %@",__func__,self.dataResultsController.fetchedObjects);
                [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            
            else {
                #warning - display error
            }
            
        }
        else {
#warning - display error
        }
    }];
}

-(void)loginAccount {
    [self showLoginProgress];
    [self.globalDataManager.invServerClient signIntoAccount:self.currentAccountId withCompletionBlock:^(INVEmpireMobileError *error) {
    [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
        if (!error) {
            self.globalDataManager.loggedInAccount = self.currentAccountId;
            
            if (self.saveAsDefault) {
                // Just ignore the error and continue logging in
                NSError* error = [self.globalDataManager saveDefaultAccountInKCForLoggedInUser:self.currentAccountId];
                if (error) {
                    NSLog(@"%s. Error: %@",__func__,error);
                }
            }
            [self notifyAccountLogin];

        }
        else {
            [self showLoginFailureAlert];
        }
    }];
}

-(void)logoutAccount {
    [self.globalDataManager.invServerClient logOffSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
            [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
        if (!error) {
            self.currentAccountId = nil;
            self.globalDataManager.loggedInAccount = nil;
            [self.globalDataManager deleteCurrentlySavedDefaultAccountFromKC];
            [self notifyAccountLogout];
        }
    }];
}

-(void)switchToSelectedAccount {
    [self.globalDataManager.invServerClient logOffSignedInAccountWithCompletionBlock:^(INVEmpireMobileError *error) {
        [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
        if (!error) {
            self.globalDataManager.loggedInAccount = nil;
            [self.globalDataManager deleteCurrentlySavedDefaultAccountFromKC];
            [self.globalDataManager.invServerClient signIntoAccount:self.currentAccountId withCompletionBlock:^(INVEmpireMobileError *error) {
                if (!error) {
                    if (self.saveAsDefault) {
                        // Just ignore the error and continue logging in
                        self.globalDataManager.loggedInAccount = self.currentAccountId;
                        NSError* error = [self.globalDataManager saveDefaultAccountInKCForLoggedInUser:self.currentAccountId];
                        if (error) {
                            NSLog(@"%s. Error: %@",__func__,error);
                        }
                    }
                    NSNumber* prevLoggedInAccount =  self.globalDataManager.loggedInAccount ;
                    [self notifySwitchFromAccount:prevLoggedInAccount];
                    
                }
                else {
                    [self showLoginFailureAlert];
                }
            }];;
        }
    }];
}

#pragma mark - helpers
-(void)showLoadProgress {
    self.collectionView.dataSource = self.dataSource;
    self.hud = [MBProgressHUD loadingViewHUD:nil];

}

-(void)setEstimatedSizeForCells {
    UICollectionViewFlowLayout* currLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    [currLayout setEstimatedItemSize:CGSizeMake((CGRectGetWidth(self.parentViewController.view.frame) - (currLayout.minimumInteritemSpacing + currLayout.collectionView.contentInset.left + currLayout.collectionView.contentInset.left))/2, currLayout.itemSize.height)];
    
}

-(void)notifyAccountLogin {
    self.accountLoginSuccess = YES;
}

-(void)notifySwitchFromAccount:(NSNumber*)prevLoggedInAccount {
#warning check why crash
  //  NSDictionary* userInfo = @{@"currentAccount":prevLoggedInAccount,@"newAccount":self.currentAccountId};
    [[NSNotificationCenter defaultCenter]postNotificationName:INV_NotificationAccountSwitchSuccess object:self userInfo:nil];
    
}

-(void)notifyAccountLogout {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:INV_NotificationAccountLogOutSuccess object:self userInfo:nil];
}

-(void)showLoginProgress {
    self.hud = [MBProgressHUD loginAccountHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}


-(void)showSaveAsDefaultAlertWithMessage:(NSString*)message {

    if (!self.alertView) {
        NSArray* objects = [[NSBundle bundleForClass:[self class]]loadNibNamed:@"INVDefaultAccountAlertView" owner:nil options:nil];
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[INVDefaultAccountAlertView class]]) {
                self.alertView = (INVDefaultAccountAlertView*)obj;
                *stop = YES;
            }
        }];
        
        self.alertView.delegate = self;
        
    }
    self.alertView.alertMessage.text = message;
    CGRect newFrame = self.alertView.frame;
    NSInteger viewWidth = self.alertView.frame.size.width;
    NSInteger viewHeight = self.alertView.frame.size.height;
    newFrame.origin.x = (self.view.frame.size.width - viewWidth)/2;
    newFrame.origin.y = (self.view.frame.size.height - viewHeight)/2;
    self.alertView.frame = newFrame;
    self.alertView.alpha = 0.0;
    [self.collectionView addSubview:self.alertView];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
         self.alertView.alpha = 0.85;
       
    } completion:^(BOOL finished) {
        
          [self.alertView setTranslatesAutoresizingMaskIntoConstraints:NO];
          [self setDefaultAccountAlertConstraints];
    }];
    
}

-(void) setDefaultAccountAlertConstraints {
    NSLayoutConstraint* xConstraint = [NSLayoutConstraint constraintWithItem:self.alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint* yConstraint = [NSLayoutConstraint constraintWithItem:self.alertView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:self.alertView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:436];
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:self.alertView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:210];
    [self.collectionView addConstraints:@[xConstraint,yConstraint,widthConstraint,heightConstraint]];

}

-(void)dismissSaveAsDefaultAlert {
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alertView.alpha = 0;
      
    } completion:^(BOOL finished) {
          [self.alertView removeFromSuperview];
    }];

}


-(void)showLoginFailureAlert {
    UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.loginFailureAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    self.loginFailureAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LOGIN_FAILURE", nil) message:NSLocalizedString(@"GENERIC_ACCOUNT_LOGIN_FAILURE_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
    [self.loginFailureAlertController addAction:action];
    [self presentViewController:self.loginFailureAlertController animated:YES completion:^{
        
    }];
}

-(void)showLogoutPromptAlertForAccount:(INVAccount*)account {
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.logoutPromptAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction* proceedAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"LOG_OUT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self logoutAccount];
    }];
    NSString* promtMesg = [NSString stringWithFormat:NSLocalizedString(@"GENERIC_ACCOUNT_LOGOUT_MESSAGE", nil) ,account.name ];
    self.logoutPromptAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ARE_YOU_SURE", nil) message:promtMesg preferredStyle:UIAlertControllerStyleAlert];
    [self.logoutPromptAlertController addAction:cancelAction];
    [self.logoutPromptAlertController addAction:proceedAction];
    [[UIView appearanceWhenContainedIn:[UIAlertController class], nil]setTintColor:[UIColor grayColor]];
    
    [self presentViewController:self.logoutPromptAlertController animated:YES completion:^{
        
    }];
}

-(void)showBlurEffect {
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView* overlayBlurView = [[UIVisualEffectView  alloc]initWithEffect:blurEffect];
    [overlayBlurView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.collectionView addSubview:overlayBlurView];
    
    
    NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:overlayBlurView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:overlayBlurView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[heightConstraint,widthConstraint]];
   
}

#pragma mark - utils
-(UIStoryboard*)mainStoryboard {
    return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:[self class]]];
}



@end
