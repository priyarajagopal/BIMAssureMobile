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


#pragma mark - KVO
NSString* const KVO_INV_LoginSuccess = @"loginSuccess";

@interface INVLoginViewController ()
@property (nonatomic,assign) BOOL loginSuccess;
@property (nonatomic,copy)NSString* userToken;
@property (nonatomic,strong)UIAlertController* loginFailureAlertController;

@end

@implementation INVLoginViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupView {
    [self.emailEntryView.layer setBorderColor:(__bridge CGColorRef)([UIColor lightGrayColor])];
    [self.emailEntryView.layer setCornerRadius:2.0f];
    [self.emailEntryView.layer setBorderWidth:1.0f];
    [self.emailEntryView.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.emailEntryView.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [self.emailEntryView.layer setShadowOpacity:0.5];
  
    [self.passwordEntryView.layer setBorderColor:(__bridge CGColorRef)([UIColor lightGrayColor])];
    [self.passwordEntryView.layer setCornerRadius:2.0f];
    [self.passwordEntryView.layer setBorderWidth:1.0f];
    [self.passwordEntryView.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.passwordEntryView.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [self.passwordEntryView.layer setShadowOpacity:0.5];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIEvent Handlers
- (IBAction)onLoginClicked:(id)sender {
    if (!self.emailTextEntry.text || self.passwordTextEntry.text) {
#pragma warning - Show alert  
    }
    [self showLoginProgress];
    [self loginToServer];
}


#pragma mark - server side
-(void)loginToServer {
    [self.globalDataManager.invServerClient signInWithUserName:self.emailTextEntry.text andPassword:self.passwordTextEntry.text withCompletionBlock:^(INVEmpireMobileError *error) {
        [self hideLoginProgress];
        if (!error) {
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
-(void)showLoginProgress {
    [self.hud setLabelText:NSLocalizedString(@"LOGGING_IN",nil)];
    [self.hud setDimBackground:YES];
    [self.hud show:YES];

}

-(void)hideLoginProgress {
    [self.hud hide:YES];
}

-(void)showLoginFailureAlert {
    UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.loginFailureAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    self.loginFailureAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LOGIN_FAILURE", nil) message:NSLocalizedString(@"GENERIC_LOGIN_FAILURE_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
    [self.loginFailureAlertController addAction:action];
    [self presentViewController:self.loginFailureAlertController animated:YES completion:^{
        
    }];
}
@end
