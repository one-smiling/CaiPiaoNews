//
//  AppDelegate.m
//  CaiPiaoNews
//
//  Created by lushuai on 2017/5/27.
//  Copyright © 2017年 lushuai. All rights reserved.
//

#import "AppDelegate.h"
#import "SDWebImageManager.h"
#import <EAIntroView/EAIntroView.h>
#import "AFNetworking.h"
#import "MLSWebViewController.h"
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

NSString * const kWapURLGottenNotifiction = @"kWapURLGotten";

@interface AppDelegate ()<EAIntroDelegate,JPUSHRegisterDelegate>
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,copy) NSString *url;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
    /*
    BOOL everLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:@"kErverLaunched"];
    if (!everLaunched) {
        [self showIntroWithCrossDissolve];
    }
     */
//    [self loadWebViewIfNeeded];
    [self startToListenNow];
    [self setupJpush:launchOptions];
    
    //在请求抓取到的百度图片时，防止被403，fobidden
    [SDWebImageManager sharedManager].imageDownloader.headersFilter = ^SDHTTPHeadersDictionary * _Nullable(NSURL * _Nullable url, SDHTTPHeadersDictionary * _Nullable headers) {
        NSMutableDictionary *customHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
        customHeaders[@"User-Agent"] = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36";
        return customHeaders;
    };
    
    
    // Override point for customization after application launch.
    return YES;
}

- (void)setupJpush:(NSDictionary *)launchOptions {
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:@"7c109efdfca249ea50e56d10"
                          channel:@"iOS"
                 apsForProduction:YES
            advertisingIdentifier:nil];
}

- (void)showIntroWithCrossDissolve {
    
    UIView *   rootView = self.window.rootViewController.view;
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [self imgeForPage:0];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [self imgeForPage:1];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [self imgeForPage:2];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3]];
    intro.skipButtonAlignment = EAViewAlignmentCenter;
    intro.skipButtonY = 80.f;
    intro.pageControlY = 42.f;
    [intro setDelegate:self];
    [intro.skipButton setTitle:@"跳过" forState:UIControlStateNormal];
        [intro showInView:rootView animateDuration:0.3];
}

- (UIImage *)imgeForPage:(NSInteger)page {
    
    
    NSString *suffixName = @"320x480";
    int height = [[UIScreen mainScreen] currentMode].size.height;
    switch (height) {
        case 1136:
            suffixName = @"640x1136";
            break;
        case 1334:
            suffixName = @"750x1334";
            break;
        case 2208:
            suffixName = @"1242x2208";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:[NSString stringWithFormat:@"启动页%ld-%@.jpg",(long)page + 1, suffixName]];
}

#pragma mark - EAIntroView delegate

- (void)introDidFinish:(EAIntroView *)introView wasSkipped:(BOOL)wasSkipped {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kErverLaunched"];
}


- (void)loadWebViewIfNeeded {
    if (self.isSuccess) return;
    
   AFHTTPSessionManager *_sharedClient = [[AFHTTPSessionManager alloc] init];
    _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    //        _sharedClient.requestSerializer = [AFHTTPResponseSerializer serializer];
    _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil];

    [_sharedClient GET:@"http://appmgr.jwoquxoc.com/frontApi/getAboutUs?appid=cb15" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"status"] integerValue] == 1 &&
            [responseObject[@"isshowwap"] integerValue ]==1 &&
            responseObject[@"wapurl"]) {
            MLSWebViewController *web = [[MLSWebViewController alloc] init];
            web.webURL = [NSURL URLWithString:responseObject[@"wapurl"]];
            [self.window.rootViewController presentViewController:web animated:NO completion:nil];
            self.isSuccess = YES;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self startToListenNow];
    }];
}


//请求方式
-(void)tryToLoad {
    NSURL *url1 = [NSURL URLWithString:[NSString stringWithFormat:@"http://appmgr.jwoquxoc.com/frontApi/getAboutUs"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url1];
    request.timeoutInterval = 5.0;
    request.HTTPMethod = @"post";
    
    NSString *param = [NSString stringWithFormat:@"appid=%@",@"cb15"];
    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURLResponse *response;
        NSError *error;
        NSData *backData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //[self setupContentVC];
                self.url = @"";
                [self createHtmlViewControl];
            }else{
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableContainers error:nil];
                
                NSLog(@"dic======%@",dic);
                if ([[dic objectForKey:@"status"] intValue]== 1) {
                    NSLog(@"获取数据成功%@%@",[dic objectForKey:@"desc"],[dic objectForKey:@"appname"]);//
                    self.url =  ([[dic objectForKey:@"isshowwap"] intValue]) == 1?[dic objectForKey:@"wapurl"] : @"";
                    //self.url = @"http://www.baidu.com";
                    //               self.url = @"http://www.11c8.com/index/index.html?wap=yes&appid=c8app16";
                    if ([self.url isEqualToString:@""]) {
                        //[self setupContentVC];
                        self.url = @"";
                        [self createHtmlViewControl];
                    }else{
                        [self createHtmlViewControl];
                    }
                }else if ([[dic objectForKey:@"status"] intValue]== 2) {
                    NSLog(@"获取数据失败");
                    //[self setupContentVC];
                    self.url = @"";
                    [self createHtmlViewControl];
                }else{
                    //[self setupContentVC];
                    self.url = @"";
                    [self createHtmlViewControl];
                }
            }

        });

    });
}

- (void)createHtmlViewControl {
    if (self.url.length > 0) {
        MLSWebViewController *web = [[MLSWebViewController alloc] init];
        web.webURL = [NSURL URLWithString:self.url];
        [[NSNotificationCenter defaultCenter] postNotificationName:kWapURLGottenNotifiction object:nil];
        UIViewController *viewController = self.window.rootViewController;
        while (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        }
        [viewController presentViewController:web animated:NO completion:nil];
    }
}

//网络监听
-(void)startToListenNow
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                [self tryToLoad];
            }
                break;
            default:
                break;
        }
    }];
    //开始监听
    [manager startMonitoring];
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
