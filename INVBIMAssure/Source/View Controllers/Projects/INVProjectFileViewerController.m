//
//  INVProjectFileViewerController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/12/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFileViewerController.h"
@import WebKit;

#pragma mark - Supported JS APIs
static NSString *const INV_JS_LOAD_VIEWER = @"loadViewer('%1$@','%2$@','%3$@')";
static NSString *const INV_JS_LOAD_SIDEBAR = @"loadSidebar('%@', '%@', '%@', '%@')";
static NSString *const INV_JS_RESET_CAMERA = @"resetCamera()";
static NSString *const INV_JS_SHOW_SHADOW = @"enableShadow(%1$@)";
static NSString *const INV_JS_TOGGLE_SELECTION = @"toggleEntitiesVisible()";
static NSString *const INV_JS_EMPHASIZE = @"showLines(%1$@)";
static NSString *const INV_JS_GLASS = @"setXRayMode(%1$@)";
static NSString *const INV_JS_GETSELECTED_ENTITIES = @"getSelectedEntities()";
static NSString *const INV_JS_GETALL_ENTITIES = @"getAllEntities()";
static NSString *const INV_JS_TOGGLE_SIDEBAR = @"toggleSidebar()";

@interface INVProjectFileViewerController () <WKNavigationDelegate, WKScriptMessageHandler>
@property (strong, nonatomic) WKWebView *webView;
@property (nonatomic, readwrite) INVGlobalDataManager *globalDataManager;
@property (nonatomic, assign) BOOL showShadow;
@property (nonatomic, assign) BOOL emphasize;
@property (nonatomic, assign) BOOL showGlassEffect;
@end

@implementation INVProjectFileViewerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.globalDataManager = [INVGlobalDataManager sharedInstance];
    [self loadWebView];
    [self loadViewer];
    [self.navigationController hidesBarsOnTap];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeWebviewObservers];
    self.globalDataManager = nil;
    self.webView = nil;
}

- (void)dealloc
{
    [self removeWebviewObservers];
}

- (void)loadWebView
{
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfig];

    self.webView.navigationDelegate = self;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.webviewContainerView addSubview:self.webView];

    [self.webviewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.webviewContainerView
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:1
                                                                           constant:0]];

    [self.webviewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.webviewContainerView
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:1
                                                                           constant:0]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadViewer
{
#ifdef _USE_LOCAL_VIEWER_
    NSString *vizFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"Visualize" ofType:@"html"];

    [self.webView loadFileURL:[NSURL URLWithString:vizFile]];
#else
    //   NSURLRequest* request = [[NSURLRequest alloc]initWithURL:[NSURL
    //   URLWithString:@"https://s3-us-west-2.amazonaws.com/mobileviewer/Visualize.html"]];
    NSURLRequest *request =
        [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://10.0.1.10:8888/WebViewer/Visualize.html"]];
    [self.webView loadRequest:request];

#endif
    [self addWebviewObservers];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    INVLogDebug();

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
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    INVLogDebug();
#warning - show error alert
}

#pragma mark - Model related
- (void)loadModel
{
    NSString *emServer = self.globalDataManager.invServerClient.empireManageServer;
    NSString *acntToken = self.globalDataManager.invServerClient.accountManager.tokenOfSignedInAccount;
    NSString *emServerUrl = [NSString stringWithFormat:@"http://%@/empiremanage/api/", emServer];
    NSString *jsToInvoke = [NSString stringWithFormat:INV_JS_LOAD_VIEWER, emServerUrl, self.fileVersionId, acntToken];

    [self executeJS:jsToInvoke];

    // Add the file version
    jsToInvoke = [NSString stringWithFormat:INV_JS_LOAD_SIDEBAR, emServerUrl, self.modelId, acntToken, self.fileVersionId];
    [self executeJS:jsToInvoke];
}

/**** Unused for now. Jquery loaded remotely
- (void)injectJQuery {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"];
    NSString *jsString = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    [self.webView evaluateJavaScript:jsString completionHandler:^(id val, NSError *error) {
        INVLogError(@"Evaluation of JS :%@",error);

    }];
}
*******/

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    INVLogDebug(@"Key path is: %@", keyPath);

    if ([keyPath isEqualToString:@"loading"]) {
        if (!self.webView.isLoading) {
        }
    }
}

#pragma mark - WKScriptMessageHandler protocol
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    INVLogInfo(@"%@", message.body);
}

#pragma mark - helpers
- (void)executeJS:(NSString *)jsToExecute
{
    [self.webView evaluateJavaScript:jsToExecute
                   completionHandler:^(id val, NSError *error) {
                       INVLogError(@"Evaluation of JS: %@", error);
                   }];
}

- (void)addWebviewObservers
{
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeWebviewObservers
{
    [self.webView removeObserver:self forKeyPath:@"loading"];
}

#pragma mark - UIEvent handlers
- (IBAction)onHomeSelected:(id)sender
{
    NSString *jsToInvoke = INV_JS_RESET_CAMERA;
    [self executeJS:jsToInvoke];
}

- (IBAction)onToggleSidebar:(id)sender
{
    NSString *jsToInvoke = INV_JS_TOGGLE_SIDEBAR;
    [self executeJS:jsToInvoke];
}

- (IBAction)onToggleSelectionSelected:(id)sender
{
    NSString *jsToInvoke = [NSString stringWithFormat:INV_JS_TOGGLE_SELECTION];
    [self executeJS:jsToInvoke];
}

- (IBAction)onEmphasizeSelected:(id)sender
{
    self.emphasize = !self.emphasize;
    NSString *jsToInvoke = [NSString stringWithFormat:INV_JS_EMPHASIZE, @(self.emphasize)];
    [self executeJS:jsToInvoke];
}

- (IBAction)onGlassViewSelected:(id)sender
{
    self.showGlassEffect = !self.showGlassEffect;
    NSString *jsToInvoke = [NSString stringWithFormat:INV_JS_GLASS, @(self.showGlassEffect)];
    [self executeJS:jsToInvoke];
}

- (IBAction)onShadowSelected:(id)sender
{
    self.showShadow = !self.showShadow;
    NSString *jsToInvoke = [NSString stringWithFormat:INV_JS_SHOW_SHADOW, @(self.showShadow)];
    [self executeJS:jsToInvoke];
}
@end
