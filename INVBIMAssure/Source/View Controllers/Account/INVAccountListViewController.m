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
#import "INVMergedFetchedResultsControler.h"
#import "INVBlockUtils.h"
#import "INVSignUpTableViewController.h"
#import "INVAccountDetailFolderCollectionReusableView.h"
#import "UIView+INVCustomizations.h"

#import <RBCollectionViewInfoFolderLayout/RBCollectionViewInfoFolderLayout.h>

#pragma mark - KVO
NSString *const KVO_INVAccountLoginSuccess = @"accountLoginSuccess";

@interface INVAccountListViewController () <INVDefaultAccountAlertViewDelegate, UICollectionViewDataSource,
    NSFetchedResultsControllerDelegate, RBCollectionViewInfoFolderLayoutDelegate>
@property (nonatomic, assign) BOOL accountLoginSuccess;
@property (nonatomic, strong) INVDefaultAccountAlertView *alertView;
@property (nonatomic, strong) INVAccountManager *accountManager;
@property (nonatomic, readwrite) INVMergedFetchedResultsControler *dataResultsController;
@property (nonatomic, strong) NSNumber *currentAccountId;
@property (nonatomic, strong) NSString *currentInviteCode;
@property (nonatomic, assign) BOOL saveAsDefault;
@property (nonatomic, strong) INVSignUpTableViewController *signUpController;
@property (nonatomic, assign) BOOL isNSFetchedResultsChangeTypeUpdated;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (readonly, nonatomic, strong) RBCollectionViewInfoFolderLayout *collectionViewLayout;

@end

@implementation INVAccountListViewController

static NSString *const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = NO;

    self.title = NSLocalizedString(@"ACCOUNTS", nil);

    // Register cell classes
    UINib *accountCellNib = [UINib nibWithNibName:@"INVAccountViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.collectionView registerNib:accountCellNib forCellWithReuseIdentifier:@"AccountCell"];

    [self.collectionView registerClass:[RBCollectionViewInfoFolderDimple class]
            forSupplementaryViewOfKind:RBCollectionViewInfoFolderDimpleKind
                   withReuseIdentifier:@"dimple"];

    [self.collectionView registerNib:[UINib nibWithNibName:@"INVAccountDetailFolderCollectionReusableView" bundle:nil]
          forSupplementaryViewOfKind:RBCollectionViewInfoFolderFolderKind
                 withReuseIdentifier:@"folder"];

    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:RBCollectionViewInfoFolderHeaderKind
                   withReuseIdentifier:@"reusable"];

    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:RBCollectionViewInfoFolderFooterKind
                   withReuseIdentifier:@"reusable"];

    if (self.hideSettingsButton) {
        self.settingsButton = nil;
    }
    else {
        FAKFontAwesome *settingsIcon = [FAKFontAwesome gearIconWithSize:30];
        [self.settingsButton setImage:[settingsIcon imageWithSize:CGSizeMake(30, 30)]];
    }

    [self setEstimatedSizeForCells];

    self.refreshControl = [UIRefreshControl new];

    [self.refreshControl addTarget:self action:@selector(fetchListOfAccounts) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self fetchListOfAccounts];

    NSNumber *defaultAcnt = self.globalDataManager.defaultAccountId;
    if (defaultAcnt && self.autoSignIntoDefaultAccount) {
        self.globalDataManager.loggedInAccount = defaultAcnt;
        self.currentAccountId = defaultAcnt;
        [self loginAccount];
    }
    else if (self.globalDataManager.invitationCodeToAutoAccept) {
        self.currentInviteCode = self.globalDataManager.invitationCodeToAutoAccept;
        [self acceptInvitationWithSelectedInvitationCode];
        self.globalDataManager.invitationCodeToAutoAccept = nil;
    }
    else {
        self.currentAccountId = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.alertView = nil;
    self.accountManager = nil;
    self.dataResultsController = nil;

    [self removeSignupObservers];
    self.signUpController = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setEstimatedSizeForCells];
}

- (void)loginLogoutAccount:(INVAccount *)account
{
    if ([self.globalDataManager.loggedInAccount isEqualToNumber:account.accountId]) {
        [self showLogoutPromptAlertForAccount:account];
    }

    else {
        self.currentAccountId = account.accountId;
        // [self showBlurEffect];

        NSString *message = (self.globalDataManager.loggedInAccount == nil) ? @"ARE_YOU_SURE_ACCOUNTLOGIN_MESSAGE"
                                                                            : @"ARE_YOU_SURE_ACCOUNTSWITCH_MESSAGE";

        message = [NSString stringWithFormat:NSLocalizedString(message, nil), account.name];

        BOOL shouldAllowSaveDefaultAccountOption = YES;
        if (!self.globalDataManager.rememberMeOptionSelected) {
            shouldAllowSaveDefaultAccountOption = NO;
        }

        [self showSaveAsDefaultAlertWithMessage:message
                           andAcceptButtonTitle:NSLocalizedString(@"LOG_INTO_ACCOUNT", nil)
                           andCancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                              showDefaultOption:shouldAllowSaveDefaultAccountOption];
    }
}

- (void)presentPendingInvitePrompt:(INVUserInvite *)invite
{
    self.currentInviteCode = invite.invitationCode;
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ARE_YOU_SURE_INVITE_MESSAGE", nil), invite.accountName];

    [self showSaveAsDefaultAlertWithMessage:message
                       andAcceptButtonTitle:NSLocalizedString(@"INVITE_ACCEPT", nil)
                       andCancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                          showDefaultOption:NO];
}

#pragma mark - UITableViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == RBCollectionViewInfoFolderDimpleKind) {
        RBCollectionViewInfoFolderDimple *dimple = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                           withReuseIdentifier:@"dimple"
                                                                                                  forIndexPath:indexPath];
        dimple.color = [UIColor colorWithRed:194.0 / 255 green:224.0 / 255 blue:240.0 / 255 alpha:1.0];

        return dimple;
    }

    if (kind == RBCollectionViewInfoFolderFolderKind) {
        INVAccountDetailFolderCollectionReusableView *folder =
            [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:@"folder"
                                                           forIndexPath:indexPath];

        folder.backgroundColor = [UIColor colorWithRed:194.0 / 255 green:224.0 / 255 blue:240.0 / 255 alpha:1.0];

        if (indexPath.section == 0) {
            folder.account = [self.dataResultsController objectAtIndexPath:indexPath];
        }
        else {
            folder.invite = [self.dataResultsController objectAtIndexPath:indexPath];
        }

        return folder;
    }

    if (kind == RBCollectionViewInfoFolderFooterKind || kind == RBCollectionViewInfoFolderHeaderKind) {
        UICollectionReusableView *reusable = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                     withReuseIdentifier:@"reusable"
                                                                                            forIndexPath:indexPath];

        return reusable;
    }

    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    INVAccountViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AccountCell" forIndexPath:indexPath];
    id accountOrInvite = [self.dataResultsController objectAtIndexPath:indexPath];

    if (indexPath.section == 0) {
        cell.account = accountOrInvite;

        NSNumber *currentAcnt = self.globalDataManager.loggedInAccount;
        if (currentAcnt && [[accountOrInvite accountId] isEqualToNumber:currentAcnt]) {
            cell.isCurrentlySignedIn = YES;
        }
        else {
            cell.isCurrentlySignedIn = NO;
        }
        if ([self.globalDataManager.defaultAccountId isEqualToNumber:cell.account.accountId]) {
            cell.isDefault = YES;
        }
        else {
            cell.isDefault = NO;
        }
    }

    if (indexPath.section == 1) {
        cell.invite = accountOrInvite;
    }

    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataResultsController.sections[section] numberOfObjects];
}

#pragma mark UICollectionViewDelegate

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionViewLayout toggleFolderViewForIndexPath:indexPath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SignUpUserSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = segue.destinationViewController;
            self.signUpController = (INVSignUpTableViewController *) navController.topViewController;
            [self addSignUpObservers];
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - INVDefaultAccountAlertViewDelegate
- (void)onAcceptButtonSelectedWithDefault:(BOOL)isDefault
{
    [self dismissSaveAsDefaultAlert];
    self.saveAsDefault = isDefault;

    NSString *buttonTitle = self.alertView.acceptButton.titleLabel.text;

    if ([buttonTitle isEqualToString:NSLocalizedString(@"INVITE_ACCEPT", nil)]) {
        [self acceptInvitationWithSelectedInvitationCode];
        return;
    }

    NSNumber *prevLoggedInAccount = self.globalDataManager.loggedInAccount;
    if (prevLoggedInAccount && (prevLoggedInAccount != self.currentAccountId)) {
        [self switchToSelectedAccount];
    }
    else {
        [self loginAccount];
    }
}

- (void)onCancelButtonSelected
{
    [self dismissSaveAsDefaultAlert];
}

#pragma mark - accessor
- (INVMergedFetchedResultsControler *)dataResultsController
{
    if (!_dataResultsController) {
        INVMergedFetchedResultsControler *mergedFetchResultsController = [[INVMergedFetchedResultsControler alloc] init];

        NSFetchRequest *fetchRequestForAccounts = self.accountManager.fetchRequestForAccountsOfSignedInUser;
        NSSortDescriptor *orderByDate = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
        [fetchRequestForAccounts setSortDescriptors:@[ orderByDate ]];

        NSManagedObjectContext *managedObjectContext = self.accountManager.managedObjectContext;
        managedObjectContext.stalenessInterval = 0;
        [mergedFetchResultsController
            addFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequestForAccounts
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil]];

        NSFetchRequest *fetchRequestForInvites = self.accountManager.fetchRequestForPendingInvitesForSignedInUser;
        [fetchRequestForInvites setSortDescriptors:@[ orderByDate ]];

        [mergedFetchResultsController
            addFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequestForInvites
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil]];

        _dataResultsController = mergedFetchResultsController;
        _dataResultsController.delegate = self;
        NSError *dbError;

        [_dataResultsController performFetch:&dbError];

        if (dbError) {
            _dataResultsController = nil;
        }
    }

    return _dataResultsController;
}

- (INVAccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = self.globalDataManager.invServerClient.accountManager;
    }
    return _accountManager;
}

#pragma mark - server side
- (void)fetchListOfAccounts
{
    [self showLoadProgress];

    [self.globalDataManager.invServerClient getAllAccountsForSignedInUserWithCompletionBlock:INV_COMPLETION_HANDLER {
        INV_ALWAYS:
        INV_SUCCESS:
            [self.globalDataManager.invServerClient getPendingInvitationsForSignedInUserWithCompletionBlock:({
                INV_COMPLETION_HANDLER
                {
                INV_ALWAYS:
                    [self.refreshControl endRefreshing];
                    [self.hud hide:YES];

                INV_SUCCESS:
                    // Note: need to explicitly do a fetch because our notification poller keeps polling for the same
                    // information from  server updating the persistent store. This implies that there is a chance that when the
                    // accounts view requests the data,there are no changes to the persistent store- so any faulted objects go
                    // out of sync with whats in the persistent store. The stalenessInterval property does not help since the
                    // persistent store is not updated in this case. This is a race condition between when the poller fetches
                    // the data thereby upating the store  versus when the accounts viewer requests this. Regardless, forcing a
                    // fetch by the FRC will ensure that the in-memory version syncs up with the data store
                    [self.dataResultsController performFetch:NULL];
                    [self.collectionView reloadData];

                INV_ERROR:
                    INVLogError(@"%@", error);

                    UIAlertController *errController = [[UIAlertController alloc]
                        initWithErrorMessage:NSLocalizedString(@"ERROR_ACCOUNT_LOAD", nil), error.code];
                    [self presentViewController:errController animated:YES completion:nil];
                };
            })];

        INV_ERROR:
            INVLogError(@"%@", error);

            UIAlertController *errController =
                [[UIAlertController alloc] initWithErrorMessage:NSLocalizedString(@"ERROR_ACCOUNT_LOAD", nil), error.code];
            [self presentViewController:errController animated:YES completion:nil];
    }];
}

- (void)loginAccount
{
    [self showLoginProgress];
    [self.globalDataManager.invServerClient
            signIntoAccount:self.currentAccountId
        withCompletionBlock:INV_COMPLETION_HANDLER {
            INV_ALWAYS:
                [self.hud hide:YES];

            INV_SUCCESS:
                self.globalDataManager.loggedInAccount = self.currentAccountId;

                if (self.saveAsDefault) {
                    // Just ignore the error and continue logging in
                    NSError *error = [self.globalDataManager saveDefaultAccountInKCForLoggedInUser:self.currentAccountId];
                    if (error) {
                        INVLogError(@"%@", error);
                    }
                }

                [self notifyAccountLogin];

            INV_ERROR:
                INVLogError(@"%@", error);
                [self showLoginFailureAlert];
        }];
}

- (void)logoutAccount
{
    [self.globalDataManager.invServerClient logOffSignedInAccountWithCompletionBlock:INV_COMPLETION_HANDLER {
        INV_ALWAYS:
        INV_SUCCESS:
            self.currentAccountId = nil;
            self.globalDataManager.loggedInAccount = nil;
            [self.globalDataManager deleteCurrentlySavedDefaultAccountFromKC];
            [self notifyAccountLogout];

        INV_ERROR:
            INVLogError(@"%@", error);
    }];
}

- (void)switchToSelectedAccount
{
    [self showLoginProgress];
    [self.globalDataManager.invServerClient logOffSignedInAccountWithCompletionBlock:INV_COMPLETION_HANDLER {
        INV_ALWAYS:
            [self.hud hide:YES];

        INV_SUCCESS:
            self.globalDataManager.loggedInAccount = nil;
            if (self.saveAsDefault) {
                [self.globalDataManager deleteCurrentlySavedDefaultAccountFromKC];
            }

            [self.globalDataManager.invServerClient signIntoAccount:self.currentAccountId
                                                withCompletionBlock:({
                                                    INV_COMPLETION_HANDLER
                                                    {
                                                    INV_ALWAYS:
                                                        [self.hud hide:YES];

                                                    INV_SUCCESS:
                                                        self.globalDataManager.loggedInAccount = self.currentAccountId;

                                                        if (self.saveAsDefault) {
                                                            // Just ignore the error and continue logging in
                                                            self.globalDataManager.loggedInAccount = self.currentAccountId;
                                                            NSError *error = [self.globalDataManager
                                                                saveDefaultAccountInKCForLoggedInUser:self.currentAccountId];
                                                            if (error) {
                                                                INVLogError(@"%@", error);
                                                            }
                                                        }

                                                        [self notifySwitchFromAccount:self.globalDataManager.loggedInAccount];

                                                    INV_ERROR:
                                                        INVLogError(@"%@", error);
                                                        [self showLoginFailureAlert];
                                                    };
                                                })];

        INV_ERROR:
            INVLogError(@"%@", error);
    }];
}

- (void)acceptInvitationWithSelectedInvitationCode
{
    NSString *userEmail = self.globalDataManager.loggedInUser;
    [self.globalDataManager.invServerClient acceptInvite:self.currentInviteCode
                                                 forUser:userEmail
                                     withCompletionBlock:INV_COMPLETION_HANDLER {
                                         INV_ALWAYS:
                                         INV_SUCCESS:
                                             [self fetchListOfAccounts];

                                         INV_ERROR:
                                             INVLogError(@"%@", error);
                                             [self showAcceptFailureAlert];

                                     }];
    self.currentInviteCode = nil;
}

#pragma mark -

#pragma mark - helpers
- (void)showLoadProgress
{
    self.hud = [MBProgressHUD loadingViewHUD:nil];
}

- (void)setEstimatedSizeForCells
{
    self.collectionViewLayout.cellSize = CGSizeMake(320, 300);
    self.collectionViewLayout.interItemSpacingX = 10;
    self.collectionViewLayout.interItemSpacingY = 10;
    self.collectionViewLayout.stickyHeaders = YES;

    // self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)notifyAccountLogin
{
    self.accountLoginSuccess = YES;
}

- (void)notifySwitchFromAccount:(NSNumber *)prevLoggedInAccount
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INV_NotificationAccountSwitchSuccess object:self userInfo:nil];
}

- (void)notifyAccountLogout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INV_NotificationAccountLogOutSuccess object:self userInfo:nil];
}

- (void)showLoginProgress
{
    self.hud = [MBProgressHUD loginAccountHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

- (void)showSaveAsDefaultAlertWithMessage:(NSString *)message
                     andAcceptButtonTitle:(NSString *)acceptButtonTitle
                     andCancelButtonTitle:(NSString *)cancelButtonTitle
                        showDefaultOption:(BOOL)showsDefaultOption
{
    if (!self.alertView) {
        NSArray *objects =
            [[NSBundle bundleForClass:[self class]] loadNibNamed:@"INVDefaultAccountAlertView" owner:nil options:nil];
        self.alertView = [objects firstObject];

        self.alertView.delegate = self;
    }

    // If default account has been specified and user wants to switch to a different account, do not have the default
    // account
    // option ON by default
    if (self.globalDataManager.defaultAccountId || !showsDefaultOption) {
        [self.alertView.defaultSwitch setOn:NO];
    }

    self.alertView.alertMessage.text = message;
    self.alertView.setAsDefaultContainer.hidden = !showsDefaultOption;

    [self.alertView.acceptButton setTitle:acceptButtonTitle forState:UIControlStateNormal];
    [self.alertView.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];

    self.alertView.alpha = 0.0;
    [self.view addSubview:self.alertView];

    [self.alertView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setDefaultAccountAlertConstraints];

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alertView.alpha = 0.85;
                     }
                     completion:nil];
}

- (void)setDefaultAccountAlertConstraints
{
    NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:self.alertView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0];
    NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:self.alertView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.alertView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:436];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.alertView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:210];
    [self.view addConstraints:@[ xConstraint, yConstraint, widthConstraint, heightConstraint ]];
}

- (void)dismissSaveAsDefaultAlert
{
    [UIView animateWithDuration:0.5
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            self.alertView.alpha = 0;
        }
        completion:^(BOOL finished) {
            [self.alertView removeFromSuperview];
        }];
}

- (void)showLoginFailureAlert
{
    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *loginFailureAlertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LOGIN_FAILURE", nil)
                                            message:NSLocalizedString(@"GENERIC_ACCOUNT_LOGIN_FAILURE_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [loginFailureAlertController addAction:action];
    [self presentViewController:loginFailureAlertController animated:YES completion:nil];
}

- (void)showAcceptFailureAlert
{
    UIAlertAction *action =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *loginFailureAlertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"INVITE_ACCEPT_FAILURE", nil)
                                            message:NSLocalizedString(@"GENERIC_ACCEPT_INVITE_FAILURE_MESSAGE", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];

    [loginFailureAlertController addAction:action];
    [self presentViewController:loginFailureAlertController animated:YES completion:nil];
}

- (void)showLogoutPromptAlertForAccount:(INVAccount *)account
{
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *proceedAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"LOG_OUT", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *action) {
                                                              [self logoutAccount];
                                                          }];

    NSString *promtMesg = [NSString stringWithFormat:NSLocalizedString(@"GENERIC_ACCOUNT_LOGOUT_MESSAGE", nil), account.name];
    UIAlertController *logoutPromptAlertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ARE_YOU_SURE", nil)
                                            message:promtMesg
                                     preferredStyle:UIAlertControllerStyleAlert];

    [logoutPromptAlertController addAction:cancelAction];
    [logoutPromptAlertController addAction:proceedAction];

    [self presentViewController:logoutPromptAlertController animated:YES completion:nil];
}

- (void)showBlurEffect
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *overlayBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [overlayBlurView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.collectionView addSubview:overlayBlurView];

    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:overlayBlurView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.collectionView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:overlayBlurView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.collectionView
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:0];

    [self.view addConstraints:@[ heightConstraint, widthConstraint ]];
}

#pragma mark - UIEvent handlers

- (IBAction)selectThumbnail:(id)sender
{
    INVAccountViewCell *cell = [sender findSuperviewOfClass:[UICollectionViewCell class] predicate:nil];

    UIAlertController *alertController = [[UIAlertController alloc] initForImageSelectionWithHandler:^(UIImage *image){
        // TODO: Update the thumbnail.
    }];

    alertController.modalPresentationStyle = UIModalPresentationPopover;

    [self presentViewController:alertController animated:YES completion:nil];

    alertController.popoverPresentationController.sourceView = sender;
    alertController.popoverPresentationController.sourceRect =
        CGRectMake(CGRectGetMidX([sender bounds]), CGRectGetMidY([sender bounds]), 0, 0);
    alertController.popoverPresentationController.permittedArrowDirections =
        UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
}

- (IBAction)signIn:(id)sender
{
    UICollectionViewCell *cell = [sender findSuperviewOfClass:[UICollectionViewCell class] predicate:nil];

    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    id accountOrInvite = [self.dataResultsController objectAtIndexPath:indexPath];

    if (indexPath.section == 0) {
        [self loginLogoutAccount:accountOrInvite];
    }
    else {
        [self presentPendingInvitePrompt:accountOrInvite];
    }
}

- (IBAction)done:(id)sener
{
    /* Do nothing */
}

- (IBAction)manualDismiss:(id)sender
{
    // Known bug: http://stackoverflow.com/questions/25654941/unwind-segue-not-working-in-ios-8
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self removeSignupObservers];
                                 self.signUpController = nil;
                             }];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    /* Do nothing */
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Note on special case:
    // The  notifications handler periodically fetches the pending invites list in the background. This results in the
    // local
    // cache getting updated with GET results - anytime the core data cache is touched, the
    // NSFetchedResultsController delegate is notified. The GET may not may not result in a change so we do not want to
    // keep
    // reloading the data.
    // if the user has manually triggered a refresh or the view is loaded, the table view is reloaded.
    if (!self.isNSFetchedResultsChangeTypeUpdated) {
        // [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    self.isNSFetchedResultsChangeTypeUpdated = (type == NSFetchedResultsChangeUpdate);
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type
{
}

#pragma mark - RBCollectionViewInfoFolderLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout
    sizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                        layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout
    heightForFolderAtIndexPath:(NSIndexPath *)indexPath
{
    static INVAccountDetailFolderCollectionReusableView *sizingView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UINib *sizingViewNib =
            [UINib nibWithNibName:NSStringFromClass([INVAccountDetailFolderCollectionReusableView class]) bundle:nil];
        sizingView = [[sizingViewNib instantiateWithOwner:nil options:nil] firstObject];
    });

    id object = [self.dataResultsController objectAtIndexPath:indexPath];

    if (indexPath.section == 0) {
        sizingView.account = object;
    }
    else {
        sizingView.invite = object;
    }

    return [sizingView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout
    sizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

#pragma mark - utils

- (void)addSignUpObservers
{
    [self.signUpController addObserver:self forKeyPath:KVO_INVSignupSuccess options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeSignupObservers
{
    [self.signUpController removeObserver:self forKeyPath:KVO_INVSignupSuccess];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:KVO_INVSignupSuccess]) {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     [self removeSignupObservers];
                                     self.signUpController = nil;
                                 }];

        [self fetchListOfAccounts];
    }
}
@end
