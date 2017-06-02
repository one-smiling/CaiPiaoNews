//
//  WebViewController.m
//  MeiDouLive
//
//  Created by SuperD on 16/7/4.
//  Copyright © 2016年 Puzhi Li. All rights reserved.
//

#import "MLSWebViewController.h"
#import "NetworkManager.h"
#import "NJKWebViewProgressView.h"
#import <Social/Social.h>

@interface MLSWebViewController ()<WKNavigationDelegate>
@property (nonatomic ,strong) NJKWebViewProgressView *progressView;
@property (nonatomic ,strong) WKWebView *webView;


@end

@implementation MLSWebViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self clearWebViewCache];
    
    
    WKWebView *webView = [[WKWebView alloc] init];
    [self.view addSubview:webView];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.navigationDelegate = self;
    
  NSLayoutConstraint *topLayout =  [NSLayoutConstraint constraintWithItem:webView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topLayoutGuide
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0];
    
    
    
    NSArray *hLayout = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)];
    NSArray *vLayout = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)];
    
    [self.view addConstraints:hLayout];
    [self.view addConstraints:vLayout];
    [self.view addConstraint:topLayout];
    
    
    self.webView = webView;
    
    NJKWebViewProgressView *progressView = [[NJKWebViewProgressView alloc] init];
//    progressView.progress = 1;
//    progressView.progressBarView.alpha = 0;
    
    [self.view addSubview:progressView];
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    
    topLayout =  [NSLayoutConstraint constraintWithItem:progressView
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.topLayoutGuide
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1
                                               constant:0];
    hLayout = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[progressView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(progressView)];
    vLayout = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[progressView(2)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(progressView)];
    
    
    [self.view addConstraints:hLayout];
    [self.view addConstraints:vLayout];
    [self.view addConstraint:topLayout];
    [progressView layoutIfNeeded];
    progressView.progress = 0.2;
    self.progressView = progressView;
    if (_webURL) {
        [self requestNews];
        [webView loadRequest:[NSURLRequest requestWithURL:_webURL]];
    }
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    
   UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareNews)];
    self.navigationItem.rightBarButtonItem = btn;
//    self.navigationItem.backBarButtonItem.action = @selector(selector);
    
    // Do any additional setup after loading the view.
}

- (void)shareNews {


    NSMutableArray *items = [NSMutableArray array];
    if (_webURL) [items addObject:_webURL];
    if (_webView.title) [items addObject:_webView.title];

    /**
     创建分享视图控制器
     ActivityItems  在执行activity中用到的数据对象数组。数组中的对象类型是可变的，并依赖于应用程序管理的数据。例如，数据可能是由一个或者多个字符串/图像对象，代表了当前选中的内容。
     Activities  是一个UIActivity对象的数组，代表了应用程序支持的自定义服务。这个参数可以是nil。
     */
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        //初始化回调方法
        UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError)
        {
            NSLog(@"activityType :%@", activityType);
            if (completed)
            {
                NSLog(@"completed");
            }
            else
            {
                NSLog(@"cancel");
            }
            
        };
        
        // 初始化completionHandler，当post结束之后（无论是done还是cancell）该blog都会被调用
        activityVC.completionWithItemsHandler = myBlock;
    }else{
        
        UIActivityViewControllerCompletionHandler myBlock = ^(NSString *activityType,BOOL completed)
        {
            NSLog(@"activityType :%@", activityType);
            if (completed)
            {
                NSLog(@"completed");
            }
            else
            {
                NSLog(@"cancel");
            }
            
        };
        // 初始化completionHandler，当post结束之后（无论是done还是cancell）该blog都会被调用
        activityVC.completionHandler = myBlock;
    }
    
    //Activity 类型又分为“操作”和“分享”两大类
    /*
     UIKIT_EXTERN NSString *const UIActivityTypePostToFacebook     NS_AVAILABLE_IOS(6_0);
     UIKIT_EXTERN NSString *const UIActivityTypePostToTwitter      NS_AVAILABLE_IOS(6_0);
     UIKIT_EXTERN NSString *const UIActivityTypePostToWeibo        NS_AVAILABLE_IOS(6_0);    //SinaWeibo
     UIKIT_EXTERN NSString *const UIActivityTypeMessage            NS_AVAILABLE_IOS(6_0);
     UIKIT_EXTERN NSString *const UIActivityTypeMail               NS_AVAILABLE_IOS(6_0);
     UIKIT_EXTERN NSString *const UIActivityTypePrint              NS_AVAILABLE_IOS(6_0);
     UIKIT_EXTERN NSString *const UIActivityTypeCopyToPasteboard   NS_AVAILABLE_IOS(6_0);
     UIKIT_EXTERN NSString *const UIActivityTypeAssignToContact    NS_AVAILABLE_IOS(6_0);
     UIKIT_EXTERN NSString *const UIActivityTypeSaveToCameraRoll   NS_AVAILABLE_IOS(6_0);
     UIKIT_EXTERN NSString *const UIActivityTypeAddToReadingList   NS_AVAILABLE_IOS(7_0);
     UIKIT_EXTERN NSString *const UIActivityTypePostToFlickr       NS_AVAILABLE_IOS(7_0);
     UIKIT_EXTERN NSString *const UIActivityTypePostToVimeo        NS_AVAILABLE_IOS(7_0);
     UIKIT_EXTERN NSString *const UIActivityTypePostToTencentWeibo NS_AVAILABLE_IOS(7_0);
     UIKIT_EXTERN NSString *const UIActivityTypeAirDrop            NS_AVAILABLE_IOS(7_0);
     */
    
    // 分享功能(Facebook, Twitter, 新浪微博, 腾讯微博...)需要你在手机上设置中心绑定了登录账户, 才能正常显示。
    //关闭系统的一些activity类型
    activityVC.excludedActivityTypes = @[];
    
    //在展现view controller时，必须根据当前的设备类型，使用适当的方法。在iPad上，必须通过popover来展现view controller。在iPhone和iPodtouch上，必须以模态的方式展现。
    [self presentViewController:activityVC animated:YES completion:nil];
    
}

- (void)requestNews {
    [NetworkManager GET:self.webURL.absoluteString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *html =  [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"");
//        NSArray *list = [self parseBaiduNews:html];
//        if (isRefresh) {
//            [self.dataList removeAllObjects];
//        }
//        [self.dataList addObjectsFromArray:list];
//        isRefresh ? [_tableView.mj_header endRefreshing] : [_tableView.mj_footer endRefreshing];
//        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"");

//        isRefresh ? [_tableView.mj_header endRefreshing] : [_tableView.mj_footer endRefreshing];
    }];

}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBackClicked:)];
    if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
        self.navigationController.navigationBar.topItem.leftBarButtonItem = btnBack;
    } else {
        self.navigationItem.leftBarButtonItem = btnBack;
    }
}

- (void)clearWebViewCache{
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                               NSUserDomainMask, YES)[0];
    NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
                            objectForKey:@"CFBundleIdentifier"];
    NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
    NSString *webKitFolderInCaches = [NSString
                                      stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];

    
    NSError *error;
    /* iOS8.0 WebView Cache的存放路径 */
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
}

//监控的实现方法：

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == _webView) {
        
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
    }
    else if ([keyPath isEqualToString:@"title"] && object == _webView) {
        if (!self.title) {
            self.title = _webView.title;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//这里的进度增加了动画，类似safari的进度效果
//
//需要注意的是销毁的时候一定要移除监控
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL         *url = navigationAction.request.URL;
    
    if (!navigationAction.targetFrame) {
        if ([app canOpenURL:url]) {
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    if ([url.scheme isEqualToString:@"tel"])
    {
        if ([app canOpenURL:url])
        {
            
            NSString *tel = [url.absoluteString stringByReplacingOccurrencesOfString:@"tel:" withString:@""];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:tel message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [app openURL:url];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
            [self presentViewController:alertController animated:YES completion:NULL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    else if ([url.scheme isEqualToString:@"mqqapi"]) {
        
        if ([app canOpenURL:url])
        {
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您未安装客户端，请安装后重试！" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:NULL]];
            [self presentViewController:alertController animated:YES completion:NULL];
        }
    }
    else if ([url.scheme isEqualToString:@"itms-appss"]) {
        if ([app canOpenURL:url]) {
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
//    else if ([url.scheme isEqualToString:kMeiDouURLScheme]) {
//        if ([self handleMeidouURL:url]) {
//            decisionHandler(WKNavigationActionPolicyCancel);
//            return;
//        }
//    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (BOOL)handleMeidouURL:(NSURL *)url {
//    if ([url.scheme isEqualToString:kMeiDouURLScheme]) {
////        ShareViewController *shareViewController = [[ShareViewController alloc] init];
////        shareViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
////        shareViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
////        [self presentViewController:shareViewController animated:YES completion:nil];
//        return YES;
//    }
    return NO;
}


// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (!self.title) {
        self.title = webView.title;
    }
    [self handleHtml];
    
}

- (void)handleHtml {
    NSString *doc = @"document.body.outerHTML";
    [self.webView evaluateJavaScript:doc
                     completionHandler:^(id _Nullable htmlStr, NSError * _Nullable error) {
                         if (error) {
                             NSLog(@"JSError:%@",error);
                         }
                         NSLog(@"html:%@",htmlStr);
                     }] ;
    
    [self.webView evaluateJavaScript:@"document.getElementsByTagName(\"p\")[0].toString()" completionHandler:^(id _Nullable htmlStr, NSError * _Nullable error) {
        if (error) {
            NSLog(@"JSError:%@",error);
        }
        NSLog(@"html:%@",htmlStr);
    }];
    
    /*
     var objectHTMLCollection = document.getElementsByTagName("div"),
     string = [].map.call( objectHTMLCollection, function(node){
     return node.textContent || node.innerText || "";
     }).join("");
     */
    
//    NSString *js = [NSString stringWithFormat:@"\
//                    var appendDiv = document.getElementById(\"AppAppendDIV\");\
//                    if (appendDiv) {\
//                    appendDiv.style.height = %@+\"px\";\
//                    } else {\
//                    var appendDiv = document.createElement(\"div\");\
//                    appendDiv.setAttribute(\"id\",\"AppAppendDIV\");\
//                    appendDiv.style.width=%@+\"px\";\
//                    appendDiv.style.height=%@+\"px\";\
//                    document.body.appendChild(appendDiv);\
//                    }\
//                    ", @(addViewHeight), @(self.webView.scrollView.contentSize.width), @(addViewHeight)];
//    
//    [self.webView evaluateJavaScript:js completionHandler:nil];
//
    
    [self.webView evaluateJavaScript:@"$(#tyler_durden_image).on('imagechanged', function(event, isSuccess) { window.webkit.messageHandlers.\(eventname).postMessage(JSON.stringify(isSuccess)) }" completionHandler: nil];

    [self.webView evaluateJavaScript:@"var objectHTMLCollection = document.getElementsByTagName(\"p\"),"
     "string = [].map.call( objectHTMLCollection, function(node){"
        "return node.textContent || node.innerText || \"\";"
    "}).join(\"\");"
                   completionHandler:^(id _Nullable html, NSError * _Nullable error) {
         if (error) {
             NSLog(@"JSError:%@",error);
         }
         NSLog(@"html:%@",html);
    
     }];
    
    }
//
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
}

-(void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)btnBackClicked:(id)sender {
    
    if ([_webView canGoBack]) {
        [_webView goBack];
        return;
    }

    if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end