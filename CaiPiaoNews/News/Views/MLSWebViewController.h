//
//  WebViewController.h
//  MeiDouLive
//
//  Created by SuperD on 16/7/4.
//  Copyright © 2016年 Puzhi Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MLSWebViewController : UIViewController

/**
 *  需要加载的URL
 */
@property(nonatomic, strong) NSURL *webURL;
@property(nonatomic, strong, readonly) WKWebView *webView;


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

@end
