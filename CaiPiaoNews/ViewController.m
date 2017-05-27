//
//  ViewController.m
//  CaiPiaoNews
//
//  Created by lushuai on 2017/5/27.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import "ViewController.h"

#import <WebKit/WebKit.h>
#import "NetworkManager.h"

@interface NSString (encode)

@end
@implementation  NSString (encode)

- (NSString *)urlEncode
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)self,
                                                                                 NULL,
                                                                                (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    WKWebView *webView = [[WKWebView alloc] init];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:webView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    
    NSString *url = [NSString stringWithFormat:@"http://news.baidu.com/ns?word=%@&tn=news&from=news&cl=2&rn=20&ct=1",[@"彩票" urlEncode]];
//        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    [NetworkManager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"");
        [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"");
    }];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
