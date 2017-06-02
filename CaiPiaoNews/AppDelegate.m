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


@interface AppDelegate ()<EAIntroDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
    BOOL everLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:@"kErverLaunched"];
    if (!everLaunched) {
        [self showIntroWithCrossDissolve];
    }
    //在请求抓取到的百度图片时，防止被403，fobidden
    [SDWebImageManager sharedManager].imageDownloader.headersFilter = ^SDHTTPHeadersDictionary * _Nullable(NSURL * _Nullable url, SDHTTPHeadersDictionary * _Nullable headers) {
        NSMutableDictionary *customHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
        customHeaders[@"User-Agent"] = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36";
        return customHeaders;
    };
    // Override point for customization after application launch.
    return YES;
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
    
    [intro showInView:rootView animateDuration:0.3];
}

- (UIImage *)imgeForPage:(NSInteger)page {
    
    
    
    
    return [UIImage imageNamed:@"启动页3-1242x2208.jpg"];
}

#pragma mark - EAIntroView delegate

- (void)introDidFinish:(EAIntroView *)introView wasSkipped:(BOOL)wasSkipped {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kErverLaunched"];
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
