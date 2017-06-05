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
#import "NJKWebViewProgress.h"


@interface MLSWebViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate> {

    NJKWebViewProgress *_progressProxy;
}
@property (nonatomic ,strong) NJKWebViewProgressView *progressView;
@property (nonatomic ,strong) UIWebView *webView;


@end

@implementation MLSWebViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self clearWebViewCache];
    

    self.automaticallyAdjustsScrollViewInsets = NO;    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview: webView];
    
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
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    CGRect barFrame;
    CGFloat progressBarHeight = 2.f;

    
    if (self.navigationController.navigationBar) {
        CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
        barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    } else {
        barFrame = CGRectMake(0, 18, [UIScreen mainScreen].bounds.size.width, progressBarHeight);
        
    }
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.progress = 0.2;
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    if (!self.navigationController.navigationBar) {
        [self.view addSubview:_progressView];
    }

    if (_webURL) {
        [webView loadRequest:[NSURLRequest requestWithURL:_webURL]];
    }

   UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareNews)];
    self.navigationItem.rightBarButtonItem = btn;
    
    // Do any additional setup after loading the view.
}


- (void)shareNews {


    NSMutableArray *items = [NSMutableArray array];
    if (_webURL) [items addObject:_webURL];
    if (self.title) [items addObject:self.title];

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


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBackClicked:)];
    if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
        self.navigationController.navigationBar.topItem.leftBarButtonItem = btnBack;
    } else {
        self.navigationItem.leftBarButtonItem = btnBack;
    }
    [self.navigationController.navigationBar addSubview:_progressView];

}

- (void)clearWebViewCache{
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
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




- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [_progressView setProgress:progress animated:YES];
    
}

//
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
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
