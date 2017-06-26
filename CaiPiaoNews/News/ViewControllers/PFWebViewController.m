//
//  PFWebViewController.m
//  PFWebViewController
//
//  Created by Cee on 9/19/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import "PFWebViewController.h"
#import "PFWebViewNavigationHeader.h"
#import <WebKit/WebKit.h>
#import "VRPhotoBrowser.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface PFWebViewController () <WKNavigationDelegate,WKScriptMessageHandler> {
    BOOL isNavigationBarHidden;
    BOOL isReaderMode;
    
    NSString *readerHTMLString;
    NSString *readerArticleTitle;
}

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *webMaskView;
@property (nonatomic, strong) CALayer *maskLayer;

@property (nonatomic, strong) WKWebView *readerWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic,copy) NSArray *images;
@end

@implementation PFWebViewController

#pragma mark - Life Cycle

- (id)initWithURL:(NSURL *)url {
    
    self.offset = SCREENWIDTH < SCREENHEIGHT ? 20.f : 0.f;
    
    self = [super init];
    if (self) {
        self.url = url;
        self.progressBarColor = [UIColor blackColor];
    }
    return self;
}

- (id)initWithURLString:(NSString *)urlString {
    
    self.offset = SCREENWIDTH < SCREENHEIGHT ? 20.f : 0.f;
    
    self = [super init];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
        self.progressBarColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [WebConsole enable];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self progressChanged:@(0.2)];

    [self setupReaderMode];
    
    [self loadWebContent];
    [self.view addSubview:self.progressView];

    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareNews)];
    self.navigationItem.rightBarButtonItem = btn;
}

- (void)shareNews {
    
    
    NSMutableArray *items = [NSMutableArray array];
    if (_url) [items addObject:_url];
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


- (void)loadWebContent {
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
        return;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    if (self.navigationController) {
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBackClicked:)];
        if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
            self.navigationController.navigationBar.topItem.leftBarButtonItem = btnBack;
        } else {
            self.navigationItem.leftBarButtonItem = btnBack;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    
    if (self.navigationController) {

    }
}

- (void)btnBackClicked:(id)sender {
    
//    if ([_webView canGoBack]) {
//        [_webView goBack];
//        return;
//    }
    
    if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.offset = SCREENWIDTH < SCREENHEIGHT ? 20.f : 0.f;
    
    self.webView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    self.progressView.frame = CGRectMake(0, 63, SCREENWIDTH, 2);
//    self.webView.hidden = YES;
    self.webMaskView.frame = self.webView.frame;
    self.readerWebView.frame = self.webView.frame;
    self.maskLayer.frame = CGRectMake(0.0f, 0.0f, _readerWebView.frame.size.width, self.maskLayer.bounds.size.height);
}

#pragma mark - Lazy Initialize

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.offset + 20.5f, SCREENWIDTH, SCREENHEIGHT - 50.5f - 20.5f - self.offset) configuration:[self configuration]];
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (UIView *)webMaskView {
    if (!_webMaskView) {
        _webMaskView = [[UIView alloc] initWithFrame:self.webView.frame];
        _webMaskView.backgroundColor = [UIColor clearColor];
        _webMaskView.userInteractionEnabled = NO;
    }
    return _webMaskView;
}

- (WKWebView *)readerWebView {
    if (!_readerWebView) {
        _readerWebView = [[WKWebView alloc] initWithFrame:self.webView.frame configuration:[self configuration]];
        _readerWebView.allowsBackForwardNavigationGestures = NO;
        _readerWebView.navigationDelegate = self;
        _readerWebView.userInteractionEnabled = NO;
        _readerWebView.layer.masksToBounds = YES;
    }
    return _readerWebView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, self.offset + 19.f, SCREENWIDTH, 2)];
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = self.progressBarColor;
    }
    return _progressView;
}

#pragma mark - Reader Mode

- (void)setupReaderMode {
    isReaderMode = NO;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.webMaskView];

    self.maskLayer = [CALayer layer];
    self.maskLayer.frame = CGRectMake(0.0f, 0.0f, self.readerWebView.frame.size.width, 0.0f);
    self.maskLayer.borderWidth = self.readerWebView.frame.size.height / 2.0f;
    self.maskLayer.anchorPoint = CGPointMake(0.5, 1.0f);
    
    [self.readerWebView.layer setMask:self.maskLayer];
    
    [self.view addSubview:self.readerWebView];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if ([change[NSKeyValueChangeNewKey] isKindOfClass:[NSNumber class]]) {
            [self progressChanged:change[NSKeyValueChangeNewKey]];
        }
    } else if ([keyPath isEqualToString:@"canGoBack"]){

    } else if ([keyPath isEqualToString:@"canGoForward"]){
    
    } else if ([keyPath isEqualToString:@"title"]){
        self.title = _webView.title;
    }
    
}

#pragma mark - Private

- (void)progressChanged:(NSNumber *)newValue {
    if (self.progressView.alpha == 0) {
        self.progressView.alpha = 1.f;
    }
    
    [self.progressView setProgress:newValue.floatValue animated:YES];
    
    if (self.progressView.progress == 1) {
        [UIView animateWithDuration:.5f animations:^{
            self.progressView.alpha = 0;
        } completion:^(BOOL finished) {
            self.progressView.progress = 0;
        }];
    } else if (self.progressView.alpha == 0){
        [UIView animateWithDuration:.1f animations:^{
            self.progressView.alpha = 1.f;
        }];
    }
}

- (WKWebViewConfiguration *)configuration {
    // Load reader mode js script
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"PFWebViewController" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    
    NSString *readerScriptFilePath = [imageBundle pathForResource:@"safari-reader" ofType:@"js"];
    NSString *readerCheckScriptFilePath = [imageBundle pathForResource:@"safari-reader-check" ofType:@"js"];
    
    NSString *indexPageFilePath = [imageBundle pathForResource:@"index" ofType:@"html"];
    
    // Load HTML for reader mode
    readerHTMLString = [[NSString alloc] initWithContentsOfFile:indexPageFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *script = [[NSString alloc] initWithContentsOfFile:readerScriptFilePath encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    NSString *check_script = [[NSString alloc] initWithContentsOfFile:readerCheckScriptFilePath encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *check_userScript = [[WKUserScript alloc] initWithSource:check_script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:userScript];
    [userContentController addUserScript:check_userScript];
    [userContentController addScriptMessageHandler:self name:@"JSController"];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;

    return configuration;
}

#pragma mark - PFWebViewToolBarDelegate



- (void)webViewSwitchReaderMode{
    isReaderMode = !isReaderMode;
    if (isReaderMode) {
        [_webView evaluateJavaScript:
          @"var ReaderArticleFinderJS = new ReaderArticleFinder(document);"
          "var article = ReaderArticleFinderJS.findArticle(); article.element.outerHTML" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
            if ([object isKindOfClass:[NSString class]] && isReaderMode) {
                [_webView evaluateJavaScript:@"ReaderArticleFinderJS.articleTitle()" completionHandler:^(id _Nullable object_in, NSError * _Nullable error) {
                    readerArticleTitle = object_in;
                    
                    NSMutableString *mut_str = [readerHTMLString mutableCopy];
                    
                    // Replace page title with article title
                    [mut_str replaceOccurrencesOfString:@"Reader" withString:readerArticleTitle options:NSLiteralSearch range:NSMakeRange(0, 300)];
                    NSRange t = [mut_str rangeOfString:@"<div id=\"article\" role=\"article\">"];
                    NSInteger location = t.location + t.length;
                    
                    NSString *t_object = [NSString stringWithFormat:@"<div style=\"position: absolute; top: -999em\">%@</div>",object];
                    [mut_str insertString:t_object atIndex:location];
                    
                    [_readerWebView loadHTMLString:mut_str baseURL:self.url];
                    _readerWebView.alpha = 0.0f;

                    [_webView evaluateJavaScript:@"ReaderArticleFinderJS.prepareToTransitionToReader();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {}];
                }];
            }
        }];
    } else {
        [UIView animateWithDuration:0.2f animations:^{
            self.webMaskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
            self.maskLayer.frame = CGRectMake(0.0f, 0.0f, _readerWebView.frame.size.width, 0.0f);
        } completion:^(BOOL finished) {
            _readerWebView.userInteractionEnabled = NO;
        }];
    }
}


#pragma mark - WKWebViewNavigationDelegate Methods

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    if ([webView isEqual:self.readerWebView]) {
        return;
    }
    
    if (![self.webView.URL.absoluteString isEqualToString:@"about:blank"]) {
        // Cache current url after every frame entering if not blank page
        self.url = self.webView.URL;
        isReaderMode = NO;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self getImageUrlByJS:webView];

    return;
    if (webView == _webView) {
        
        // Set reader mode button status when navigation finished
        [webView evaluateJavaScript:@"var ReaderArticleFinderJS = new ReaderArticleFinder(document); ReaderArticleFinderJS.isReaderModeAvailable();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
            if ([object integerValue] == 1) {
//                [self webViewSwitchReaderMode];
            } else {
//                [self webViewSwitchReaderMode];
            }
        }];
    }
    
    if (webView == _readerWebView) {
        [self getImageUrlByJS:webView];
    }
    
}

// 拦截非 Http:// 和 Https:// 开头的请求，转成应用内跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([self showBigImage:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyCancel);

    } else if (![navigationAction.request.URL.absoluteString containsString:@"http://"] && ![navigationAction.request.URL.absoluteString containsString:@"https://"]) {
        
        UIApplication *application = [UIApplication sharedApplication];
#ifndef __IPHONE_10_0
#define __IPHONE_10_0  100000
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        } else {
            [application openURL:navigationAction.request.URL];
        }
#else
        [application openURL:navigationAction.request.URL];
#endif
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    _readerWebView.alpha = 1.0f;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.webMaskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
            self.maskLayer.frame = CGRectMake(0.0f, 0.0f, _readerWebView.frame.size.width, _readerWebView.frame.size.height);
        } completion:^(BOOL finished) {
            _readerWebView.userInteractionEnabled = YES;
        }];
    });
}



//方法一：通过js获取网页图片数组

/*
 *通过js获取htlm中图片url
 */
-(void)getImageUrlByJS:(WKWebView *)wkWebView
{
    
    //查看大图代码
    //js方法遍历图片添加点击事件返回图片个数
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgUrlStr='';\
    for(var i=0;i<objs.length;i++){\
        if(i==0){\
            if(objs[i].alt==''){\
                imgUrlStr=objs[i].src;\
            }\
        }else{\
            if(objs[i].alt==''){\
                imgUrlStr+='#'+objs[i].src;\
            }\
        }\
        objs[i].onclick=function(){\
            if(this.alt==''){\
                document.location=\"myweb:imageClick:\"+this.src;\
            }\
        };\
    };\
    return imgUrlStr;\
    };";

    //用js获取全部图片
    [wkWebView evaluateJavaScript:jsGetImages completionHandler:^(id Result, NSError * error) {
        NSLog(@"js___Result==%@",Result);
        NSLog(@"js___Error -> %@", error);
    }];


    NSString *js2=@"getImages()";
    [wkWebView evaluateJavaScript:js2 completionHandler:^(id Result, NSError * error) {
        NSLog(@"js2__Result==%@",Result);
        NSLog(@"js2__Error -> %@", error);
        NSString *resurlt=[NSString stringWithFormat:@"%@",Result];
        if([resurlt hasPrefix:@"#"])
        {
            resurlt=[resurlt substringFromIndex:1];
        }
        NSLog(@"result===%@",resurlt);
        self.images = [resurlt componentsSeparatedByString:@"#"];
    }];

}

//方法二：显示大图

//显示大图
-(BOOL)showBigImage:(NSURLRequest *)request
{
    //将url转换为string
    NSString *requestString = [[request URL] absoluteString];
    
    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
    if ([requestString hasPrefix:@"myweb:imageClick:"])
    {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        NSLog(@"image url------%@", imageUrl);
        
        NSArray *imgUrlArr=self.images;
        NSInteger index=0;
        for (NSInteger i=0; i<[imgUrlArr count]; i++) {
            if([imageUrl isEqualToString:imgUrlArr[i]])
            {
                index=i;
                break;
            }
        }
        [self showImageWithIndex:index];
        return YES;
    }
    return NO;
}


- (void)showImageWithIndex:(NSInteger)beginIndex {
    // Create browser
    VRPhotoBrowser *browser = [[VRPhotoBrowser alloc] init];
    browser.delegate = browser;
    browser.albumsData = self.images;
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = YES;
    [browser setCurrentPhotoIndex:beginIndex];
    [self.navigationController pushViewController:browser animated:YES];
}


@end
