//
//  INVProjectFileViewerController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/12/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFileViewerController.h"
@import  WebKit;

#pragma mark - Supported JS APIs
static NSString* const INV_JS_LOAD_VIEWER = @"loadViewer('%1$@','%2$@','%3$@')";
static NSString* const INV_JS_RESET_CAMERA = @"resetCamera()";
static NSString* const INV_JS_SHOW_SHADOW = @"enableShadow(%1$@)";
static NSString* const INV_JS_TOGGLE_SELECTION = @"toggleEntitiesVisible()";
static NSString* const INV_JS_EMPHASIZE = @"showLines(%1$@)";
static NSString* const INV_JS_GLASS = @"setXRayMode(%1$@)";
static NSString* const INV_JS_GETSELECTED_ENTITIES = @"getSelectedEntities()";
static NSString* const INV_JS_GETALL_ENTITIES = @"getAllEntities()";

@interface INVProjectFileViewerController ()<WKNavigationDelegate, WKScriptMessageHandler>
@property (strong, nonatomic)  WKWebView *webView;
@property (nonatomic,readwrite)INVGlobalDataManager* globalDataManager;
@property (nonatomic,assign)BOOL showShadow;
@property (nonatomic,assign)BOOL emphasize;
@property (nonatomic,assign)BOOL showGlassEffect;
@end

@implementation INVProjectFileViewerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.globalDataManager = [INVGlobalDataManager sharedInstance];
    [self loadWebView];
    [self loadViewer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSURLCache sharedURLCache]removeAllCachedResponses];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.splitViewController setPreferredDisplayMode : UISplitViewControllerDisplayModePrimaryHidden ];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController hidesBarsOnTap];
    
  }

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.splitViewController setPreferredDisplayMode : UISplitViewControllerDisplayModeAllVisible ];
    [self removeWebviewObservers];
    self.webView = nil;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}



-(void)loadWebView {
    WKWebViewConfiguration* webConfig = [[WKWebViewConfiguration alloc]init];
    self.webView = [[WKWebView alloc]initWithFrame:self.view.frame configuration:webConfig];
    self.webView.navigationDelegate = self;
    [self.webviewContainerView addSubview:self.webView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)loadViewer {
    
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://s3-us-west-2.amazonaws.com/mobileviewer/Visualize.html"]];
   //  NSURLRequest* request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://10.0.1.3:8888/Viewer/Visualize.html"]];
    //NSURLRequest* request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://192.168.1.199:8888/XOSVisualization/sample/index.html"]];
    [self.webView loadRequest:request];
    [self addWebviewObservers] ;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"%s",__func__);
    #pragma Handle JS events
    [self loadModel];

}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigatio
 n.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%s",__func__);
#warning - show error alert
    
}

#pragma mark - Model related
-(void)loadModel {
    NSString* emServer = self.globalDataManager.invServerClient.empireManageServer;
    NSString* acntToken = self.globalDataManager.invServerClient.accountManager.tokenOfSignedInAccount;
    NSString* emServerUrl =  [NSString stringWithFormat:@"http://%@/empiremanage/api/",emServer];
    NSString* jsToInvoke = [NSString stringWithFormat:INV_JS_LOAD_VIEWER,emServerUrl,self.modelId,acntToken];
    [self executeJS:jsToInvoke];
    
}

/**** Unused for now. Jquery loaded remotely
- (void)injectJQuery {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"];
    NSString *jsString = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    [self.webView evaluateJavaScript:jsString completionHandler:^(id val, NSError *error) {
        NSLog(@"Evaluation of JS :%@",error);
        
    }];
}
*******/


#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%s with keyPath %@",__func__,keyPath);
    if ([keyPath isEqualToString:@"loading"]) {
        if (!self.webView.isLoading) {
            
        }
    }
}

#pragma mark - WKScriptMessageHandler protocol
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%s with message %@",__func__,message.body);
}

#pragma mark - helpers
-(void)executeJS:(NSString*)jsToExecute {
    [self.webView evaluateJavaScript:jsToExecute completionHandler:^(id val, NSError *error) {
        NSLog(@"Evaluation of JS :%@",error);
#warning display error
    }];
}

-(void)addWebviewObservers {
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    
}
-(void)removeWebviewObservers {
    [self.webView removeObserver:self forKeyPath:@"loading"];
    
}

#pragma mark - UIEvent handlers
- (IBAction)onHomeSelected:(id)sender {
    NSString* jsToInvoke = INV_JS_RESET_CAMERA;
    [self executeJS:jsToInvoke];
}

- (IBAction)onToggleSelectionSelected:(id)sender {
     NSString* jsToInvoke = [NSString stringWithFormat:INV_JS_TOGGLE_SELECTION];
    [self executeJS:jsToInvoke];
}

- (IBAction)onEmphasizeSelected:(id)sender {
    self.emphasize = !self.emphasize;
    NSString* jsToInvoke = [NSString stringWithFormat:INV_JS_EMPHASIZE,@(self.emphasize)];
    [self executeJS:jsToInvoke];
}

- (IBAction)onGlassViewSelected:(id)sender {
    self.showGlassEffect = !self.showGlassEffect;
    NSString* jsToInvoke = [NSString stringWithFormat:INV_JS_GLASS,@(self.showGlassEffect)];
    [self executeJS:jsToInvoke];

}

- (IBAction)onShadowSelected:(id)sender {
    self.showShadow = !self.showShadow;
    NSString* jsToInvoke = [NSString stringWithFormat:INV_JS_SHOW_SHADOW,@(self.showShadow)];
    [self executeJS:jsToInvoke];
}
@end
