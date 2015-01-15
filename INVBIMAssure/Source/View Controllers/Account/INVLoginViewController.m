//
//  INVLoginViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/6/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

@import QuartzCore;
@import EmpireMobileManager;
#import "INVLoginViewController.h"
#import "INVSignUpTableViewController.h"

#pragma mark - KVO
NSString* const KVO_INVLoginSuccess = @"loginSuccess";

@interface INVLoginViewController ()<UIScrollViewDelegate, UITextFieldDelegate>
@property (nonatomic,assign) BOOL loginSuccess;
@property (nonatomic,copy)NSString* userToken;
@property (nonatomic,strong)UIAlertController* loginFailureAlertController;
@property (nonatomic,assign)BOOL saveCredentials;
@property (nonatomic,strong)INVSignUpTableViewController* signupController;

@end

@implementation INVLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSDictionary* savedCredentials = self.globalDataManager.credentials;
    NSString* loggedInUser = savedCredentials[INV_CredentialKeyEmail];
    NSString* loggedInPass = savedCredentials[INV_CredentialKeyPassword];
    if (loggedInPass && loggedInUser) {
        self.emailTextEntry.text = loggedInUser;
        self.passwordTextEntry.text = loggedInPass;
        [self loginToServerWithUser:loggedInUser andPassword:loggedInPass];
    }
    else {
        self.emailTextEntry.text = @"";
        self.passwordTextEntry.text = @"";
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.userToken = nil;
    self.loginFailureAlertController = nil;
    [self removeSignupObservers];
    self.signupController = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupView {
    [self setLayerShadowForView:self.emailEntryView];
    [self setLayerShadowForView:self.passwordEntryView];

    self.rememberMe.titleLabel.frame = self.rememberMe.frame;
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];
    
    [self.loginButton setEnabled:NO];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SignUpSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* navController = (UINavigationController*) segue.destinationViewController;
            self.signupController = (INVSignUpTableViewController*) navController.topViewController;
            self.signupController.shouldSignUpUser = YES;
            [self addSignUpObservers];

        }
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(IBAction)done:(UIStoryboardSegue*)segue {
    NSLog(@"%s",__func__);
    [self removeSignupObservers];
    self.signupController = nil;
}

#pragma mark - UIEvent Handlers
- (IBAction)onLoginClicked:(id)sender {
    if (!self.emailTextEntry.text || !self.passwordTextEntry.text || ![self isValidEmailEntry]) {
        UIAlertController* errController = [[UIAlertController alloc]initWithErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"ERROR_INVALID_LOGIN_PARAMS", nil),INV_ERROR_CODE_INVALIDREQUESTPARAM]];
        [self presentViewController:errController animated:YES completion:^{ }];
        return;
    }
    [self loginToServerWithUser:self.emailTextEntry.text andPassword:self.passwordTextEntry.text];
}

- (IBAction)onRememberMeClicked:(id)sender {
    self.saveCredentials = !self.saveCredentials;
    
    if (self.saveCredentials) {
        [self.rememberMe setSelected:YES];
     }
    else {
        [self.rememberMe setSelected:NO];
    }
}


#pragma mark - server side
-(void)loginToServerWithUser:(NSString*)user andPassword:(NSString*)password {
    [self showLoginProgress ];
    [self.globalDataManager.invServerClient signInWithUserName:user andPassword:password withCompletionBlock:^(INVEmpireMobileError *error) {
        [self hideLoginProgress];
        if (!error) {
            if (self.saveCredentials) {
                [self saveCredentialsInKC];
            }
            self.globalDataManager.loggedInUser = self.emailTextEntry.text;
            self.userToken = self.globalDataManager.invServerClient.accountManager.tokenOfSignedInUser;
            
            NSLog(@"%s. Result of signing in is %@. TOken is %@",__func__,error, self.userToken);
            self.loginSuccess = YES;
        }
        else {
            [self showLoginFailureAlert];
            
        }
    }];
}


#pragma mark - helpers
-(void) saveCredentialsInKC {
    NSError* error = [self.globalDataManager saveCredentialsInKCForLoggedInUser:self.emailTextEntry.text withPassword:self.passwordTextEntry.text ];
    if (error) {
        // silently ignoring error
        NSLog(@"%s. Failed with %@",__func__,error);
    }
}

-(void)showLoginProgress {
    self.hud = [MBProgressHUD loginUserHUD:nil];
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}

-(void)hideLoginProgress {
     [self.hud performSelectorOnMainThread:@selector(hide:) withObject:@YES waitUntilDone:NO];
     
}

-(void)showLoginFailureAlert {
    UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.loginFailureAlertController dismissViewControllerAnimated:YES completion:nil];
        self.passwordTextEntry.text = nil;
        [self hideLoginProgress];
        
    }];
    self.loginFailureAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LOGIN_FAILURE", nil) message:NSLocalizedString(@"GENERIC_LOGIN_FAILURE_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
    [self.loginFailureAlertController addAction:action];
    [self presentViewController:self.loginFailureAlertController animated:YES completion:^{
        
    }];
}

-(BOOL) isValidEmailEntry {
    NSString* email = self.emailTextEntry.text;
    return [email isValidEmail];
}

-(void)setLayerShadowForView:(UIView*)view {
    [view.layer setBorderColor:(__bridge CGColorRef)([UIColor lightGrayColor])];
    [view.layer setCornerRadius:2.0f];
    [view.layer setBorderWidth:1.0f];
    [view.layer setShadowOffset:CGSizeMake(0, 0)];
    [view.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [view.layer setShadowOpacity:0.5];
}

-(void)addSignUpObservers {
    [self.signupController addObserver:self forKeyPath:KVO_INVSignupSuccess options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeSignupObservers {
    [self.signupController removeObserver:self forKeyPath:KVO_INVSignupSuccess];
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passwordTextEntry) {
        [textField resignFirstResponder];
    }
    else if (textField == self.emailTextEntry) {
        [self.passwordTextEntry becomeFirstResponder];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger length = textField.text.length - range.length + string.length;
    
    UITextField* otherTextField = textField == self.emailTextEntry ? self.passwordTextEntry:self.emailTextEntry;
    if (length > 0 && otherTextField.text.length ) {
        self.loginButton.enabled = YES;
    } else {
        self.loginButton.enabled = NO;
    }
    return YES;
}


#pragma mark - Keyboard Notifications

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.loginButton.frame.origin) ) {
        [self.contentScrollView scrollRectToVisible:self.loginButton.frame animated:YES];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentScrollView.contentInset = contentInsets;
    self.contentScrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - KBO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%s",__func__);
    if ([keyPath isEqualToString:KVO_INVSignupSuccess]) {
     
        NSString* signedupEmail = self.signupController.signupEmail;
        NSString* signedupPassword = self.signupController.signupPassword;
        BOOL invitationCodeEntered = self.signupController.invitationCode.length > 0;
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self removeSignupObservers];
            self.signupController = nil;
        }];
        if (self.signupController.signupSuccess) {
            [self loginToServerWithUser:signedupEmail andPassword:signedupPassword];
        }
    }
}


@end
