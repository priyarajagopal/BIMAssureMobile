//
//  INVMainViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/14/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVMainViewController.h"
#import "INVMainMenuViewController.h"

@interface INVMainViewController ()
@property (nonatomic,assign)BOOL registeredForMainMenuEvents;
@property (nonatomic,strong)INVMainMenuViewController* mainMenuVC;
@end

@implementation INVMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self deregisterMainMenuObservers];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"MainMenuEmbedSegue"]) {
        self.mainMenuVC = segue.destinationViewController;
        [self registerMainMenuObservers];
    }
}


#pragma mark - helpers
-(void)registerMainMenuObservers {
    if (self.registeredForMainMenuEvents) {
        return;
    }
    self.registeredForMainMenuEvents = YES;
    [self.mainMenuVC addObserver:self forKeyPath:INV_KVO_ONACCOUNTSMENUSELECTED options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:INV_KVO_ONPROJECTSMENUSELECTED options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:INV_KVO_ONUSERPROFILEMENUSELECTED options:NSKeyValueObservingOptionNew context:nil];
    [self.mainMenuVC addObserver:self forKeyPath:INV_KVO_ONSETTINGSMENUSELECTED options:NSKeyValueObservingOptionNew context:nil];
    
}

-(void)deregisterMainMenuObservers {
    if (!self.registeredForMainMenuEvents) {
        return;
    }
    self.registeredForMainMenuEvents = NO;
    [self.mainMenuVC removeObserver:self forKeyPath:INV_KVO_ONACCOUNTSMENUSELECTED];
    [self.mainMenuVC removeObserver:self forKeyPath:INV_KVO_ONPROJECTSMENUSELECTED ];
    [self.mainMenuVC removeObserver:self forKeyPath:INV_KVO_ONUSERPROFILEMENUSELECTED];
    [self.mainMenuVC removeObserver:self forKeyPath:INV_KVO_ONSETTINGSMENUSELECTED];
}


#pragma mark - KVO Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%s. with keyPath %@",__func__,keyPath);
}

@end
