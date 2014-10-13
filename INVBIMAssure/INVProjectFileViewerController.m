//
//  INVProjectFileViewerController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/12/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFileViewerController.h"
@import  WebKit;

@interface INVProjectFileViewerController ()<WKNavigationDelegate, WKScriptMessageHandler>
@property (strong, nonatomic)  WKWebView *webView;
@property (nonatomic,readwrite)INVGlobalDataManager* globalDataManager;

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
  }

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.splitViewController setPreferredDisplayMode : UISplitViewControllerDisplayModeAllVisible ];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeWebviewObservers];
}



-(void)loadWebView {
    WKWebViewConfiguration* webConfig = [[WKWebViewConfiguration alloc]init];
    self.webView = [[WKWebView alloc]initWithFrame:self.webviewContainerView.frame configuration:webConfig];
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
    
       NSURLRequest* request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://10.1.10.228:8888/Viewer/Visualize.html"]];
    //NSURLRequest* request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://192.168.1.199:8888/XOSVisualization/sample/index.html"]];
    [self.webView loadRequest:request];
    [self addWebviewObservers] ;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"%s",__func__);
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
#pragma warning - show error alert
    
}

#pragma mark - Model related
-(void)loadModel {
    //183782
    
    //66716
    NSString* emServer = self.globalDataManager.invServerClient.empireManageServer;
    NSString* acntToken = self.globalDataManager.invServerClient.accountManager.tokenOfSignedInAccount;
    
    NSString* paramString = [NSString stringWithFormat:@"\'http://%@/empiremanage/api/\',\'%@\',\'%@\'",emServer,self.modelId,acntToken];
    NSLog(@"%s, param string :%@",__func__,paramString);
 
    
  //  NSString* js2ToInvoke = @"loadViewer('http://54.191.225.36:8080/empiremanage/api/','183782','eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6ImZvb0Bub3doZXJlLmNvbSIsImhhc2giOiJPYzU0REN1eWdiY2MwYzU4MzcwNzEwMTI0ZWJkMTE5ZTY5MzFlNjA0MSIsIm5hbWUiOiJmb28iLCJ1c2VyaWQiOjIsImFjY291bnR0eXBlIjoiMSIsImFjY291bnRpZCI6MX0.SiabD0PTHPVHIUx8SXboN7KNAcWjmK9vGaKs7j1Io-Y')";
    NSString* js2ToInvoke = [ NSString stringWithFormat:@"loadViewer(%@)",paramString ];
    [self.webView evaluateJavaScript:js2ToInvoke completionHandler:^(id val, NSError *error) {
        NSLog(@"Evaluation of JS :%@",error);
    }];
    
}

- (void)injectJQuery {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"];
    NSString *jsString = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    [self.webView evaluateJavaScript:jsString completionHandler:^(id val, NSError *error) {
        NSLog(@"Evaluation of JS :%@",error);
        
    }];
}

#pragma mark - UIEvent Handlers
- (IBAction)onButtonTapped:(id)sender {
    NSString* jsToInvoke = @"resetCamera()";
    [self.webView evaluateJavaScript:jsToInvoke completionHandler:^(id val, NSError *error) {
        NSLog(@"Evaluation of JS :%@",error);
    }];
}

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

-(void)addWebviewObservers {
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    
}
-(void)removeWebviewObservers {
    [self.webView removeObserver:self forKeyPath:@"loading"];
    
}

@end
