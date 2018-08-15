//
//  TFWebViewController.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFWebViewController.h"
#import "TFCoreFoundationMacro.h"
#import "TFCGUtilities.h"
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import "TFDefaultStyle.h"
#import "UIViewController+EmptyState.h"

@interface TFWebViewController()<UIWebViewDelegate,NJKWebViewProgressDelegate> {
    BOOL firstLoaded;
}

@property (nonatomic ,strong) WebViewJavascriptBridge *briage;
@property (nonatomic ,strong) NJKWebViewProgress      *progressProxy;
@property (nonatomic ,strong) NJKWebViewProgressView  *progressView;

@end

@implementation TFWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (!_url && [self.params objectForKey:@"url"]) {
            self.url = [self.params objectForKey:@"url"];
        }
    }
    return self;
}

- (id)initWithUrl:(NSString *)url
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        _url = url;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)registerBridgeHandler {
    @weakify(self);
    [_briage registerHandler:@"closeWebView" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        [self closeAction];
    }];
}

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.webView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_url.length==0) {
            NSURL *url = self.params[kTFNavigatorParameterUserInfo][@"url"];
            _url = url.absoluteString;

    }
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_url.length) {
        if (!firstLoaded) {
            
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
            firstLoaded = YES;
        }
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_webView stopLoading];
    _webView = nil;
}

- (void)dealloc {
    [_webView stopLoading];
    _webView.delegate = nil;
    _progressProxy.webViewProxyDelegate = nil;
    _progressProxy.progressDelegate = nil;
}


#pragma mark - Private
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _webView.scalesPageToFit = YES;
        
        _briage = [WebViewJavascriptBridge bridgeForWebView:_webView];
        [self registerBridgeHandler];
        
        _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
        _webView.delegate = _progressProxy;
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = _progressProxy;
        
        CGFloat progressBarHeight = 2.f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
    }
    return _webView;
}


- (void)onLeftNavClick:(id)sender {
    
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    else {
        [self closeAction];
    }
}

- (void)onRightNavClick:(id)sender {
    
}

- (void)closeAction {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)openURL:(NSURL*)URL {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    [_webView loadRequest:request];
    [self setUrl:URL.absoluteString];
}


#pragma mark -
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}


- (void)updateLeftBarButton {
}

-(NSString *) routerUrlWithString:(NSString *)string key:(NSString *) key {
    NSArray *array = [string componentsSeparatedByString:key];
    if (array.count > 1) {
        return [array objectAtIndex:1];
    }
    
    return @"";
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
    self.title = NSLocalizedString(@"正在加载...", @"");
    [self updateLeftBarButton];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidFinishLoad:(UIWebView*)webView {
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self tf_removeStateView];
    [self updateLeftBarButton];
}


- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    [self webViewDidFinishLoad:webView];
    if (error) {
        [self tf_showStateView:kTFViewStateDataError];
    }
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [_progressView setProgress:progress animated:YES];
}


@end
