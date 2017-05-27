//
//  ViewController.m
//  CaiPiaoNews
//
//  Created by lushuai on 2017/5/27.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import "ViewController.h"

#import <WebKit/WebKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebView *webView = [[WKWebView alloc] init];
    [self.view addSubview:webView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    NSURL *url = [NSURL URLWithString:@"http://news.baidu.com/ns?word=彩票&tn=news&from=news&cl=2&rn=20&ct=1"];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
