//
//  TFWebViewController.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFViewController.h"

@interface TFWebViewController : TFViewController

@property (nonatomic ,strong) UIWebView *webView;
@property (nonatomic ,copy) NSString *url;

- (id)initWithUrl:(NSString *)url;
- (void)openURL:(NSURL*)URL;


- (void)registerBridgeHandler;
@end
