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
#import "MLSWebViewController.h"
#import "NewsCell.h"
#import <MJRefresh.h>


@interface NSString (Handle)

@end
@implementation  NSString (Handle)

- (NSString *)urlEncode
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)self,
                                                                                 NULL,
                                                                                (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

- (NSString *)clearStrings:(NSArray *)strings {
        NSString *aString = self;
    
    for (NSString *delete in strings) {
        if ([delete isKindOfClass:[NSString class]]) {
            aString = [aString stringByReplacingOccurrencesOfString:delete withString:@""];
        }
    }
    return aString;
}

@end

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign,nonatomic) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataList = [NSMutableArray array];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshData];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self moreData];
    }];
    
    [self requestNetwork];

      // Do any additional setup after loading the view, typically from a nib.
}

- (void)refreshData {
    _page = 0;
    [self requestNetwork];
}

- (void)moreData {
    _page++;
    [self requestNetwork];
}

- (BOOL)isRefresh {
    return _page == 0;
}

- (void)requestNetwork {
//    http://news.baidu.com/ns?word=彩票&pn=40&cl=2&ct=1&tn=news&rn=20&ie=utf-8&bt=0&et=0&rsv_page=1
//
    NSString *url = [NSString stringWithFormat:@"http://news.baidu.com/ns?word=%@&pn=%ld&cl=2&ct=1&tn=news&rn=20&ie=utf-8&bt=0&et=0",[@"彩票" urlEncode],(long)_page * 20];
    BOOL isRefresh = self.isRefresh;
    [NetworkManager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *html =  [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSArray *list = [self parseBaiduNews:html];
        if (isRefresh) {
            [self.dataList removeAllObjects];
        }
        [self.dataList addObjectsFromArray:list];
        isRefresh ? [_tableView.mj_header endRefreshing] : [_tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        isRefresh ? [_tableView.mj_header endRefreshing] : [_tableView.mj_footer endRefreshing];
    }];

}

- (NSArray *)parseBaiduNews:(NSString *)htmlString {
    
    /*
     <div class="result" id="1"><h3 class="c-title"><a href="http://video.sina.com.cn/p/news/o/doc/2017-05-28/084266334859.html?opsubject_id=top3"
     data-click="{
     'f0':'77A717EA',
     'f1':'9F63F1E4',
     'f2':'4CA6DE6E',
     'f3':'54E5343F',
     't':'1495933905'
     }"
     
     target="_blank"
     
     >近日,山西太原一<em>彩票</em>店店主刘师傅,帮彩民代买了一张<em>彩票</em></a></h3><div class="c-summary c-row "><p class="c-author">新浪视频&nbsp;&nbsp;29分钟前</p>近日,山西太原一<em>彩票</em>店店主刘师傅,帮彩民代买了一张<em>彩票</em> 按住此条可拖动相关视频 猜你喜欢 新闻- 热门视频 正在加载...请稍等~ 收藏 分享到: ...  <span class="c-info"><a href="/ns?word=%E5%BD%A9%E7%A5%A8+cont:3284382691&same=3&cl=1&tn=news&rn=30&fm=sd" class="c-more_link" data-click="{'fm':'sd'}" >3条相同新闻</a>&nbsp;&nbsp;-&nbsp;&nbsp;<a href="http://cache.baidu.com/c?m=9f65cb4a8c8507ed4fece76310528c304e0997634b968b492cc3933fc23904564711b2e73a600d5884803d7a5cb21f01bbed3670340637b7edca8f5dddcd9222328a2d327018824013d513a8c05125b67ad605b7b81893e7b273d4fe8a848e1244cd275e2c97f1fd1c5d56cb7bb54971b5a98e38154861c9fa4161e82974&amp;p=8566c64ad4934eab58b88f35524c&amp;newp=85759a41d69112a05abad662590a92695912c10e3bd5c44324b9d71fd325001c1b69e3b823281603d4c6786c15e9241dbdb239256b5572&user=baidu&fm=sc&query=%B2%CA%C6%B1&qid=eb8cdfb70008b7d2&p1=1"
     data-click="{'fm':'sc'}"
     target="_blank"  class="c-cache">百度快照</a></span></div></div>
     */
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"NewsList" ofType:@"txt"];
//    htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSRegularExpression *aNewsDiv = [NSRegularExpression regularExpressionWithPattern:@"<div class=\"result\"[^(百度快照)]*百度快照" options:0 error:nil];
    NSRegularExpression *newsRegex = [NSRegularExpression regularExpressionWithPattern:@"<h3.*?h3>" options:0 error:nil];
    NSRegularExpression *URLRegex=[NSRegularExpression regularExpressionWithPattern:@"href=(\"|')[^(\"|')]*(\"|')" options:0 error:nil];
    NSRegularExpression *aTagRegex=[NSRegularExpression regularExpressionWithPattern:@"<a[^>]*>" options:0 error:nil];

//    <p class="c-author">新浪视频&nbsp;&nbsp;29分钟前</p>
    NSRegularExpression *authorRegex = [NSRegularExpression regularExpressionWithPattern:@"<p class=\"c-author\">[^>]*</p>" options:0 error:nil];
    

    NSArray *resultAry = [aNewsDiv matchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length)];
    NSMutableArray *models = [NSMutableArray array];
    
    for (NSTextCheckingResult *result in resultAry) {
        NSString *news = [htmlString substringWithRange:result.range];
        news = [news stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *authorTime = nil;
       NSRange authorRange = [authorRegex rangeOfFirstMatchInString:news options:0 range:NSMakeRange(0, news.length)];
        if (authorRange.length != 0) {
            authorTime = [news substringWithRange:authorRange];
            authorTime = [authorTime clearStrings:@[@"<p class=\"c-author\">",@"</p>"]];
           authorTime = [authorTime stringByReplacingOccurrencesOfString:@"&nbsp;&nbsp;" withString:@"  "];
        }
        
        
        
        NSTextCheckingResult *realNews = [newsRegex firstMatchInString:news options:0 range:NSMakeRange(0, news.length)];
        if (realNews) {
            news = [news substringWithRange:realNews.range];
            NSTextCheckingResult * hrefResult = [URLRegex firstMatchInString:news options:0 range:NSMakeRange(0, news.length)];
            NSString *link = nil;
            if (hrefResult) {
                link = [news substringWithRange:NSMakeRange(hrefResult.range.location+5, hrefResult.range.length-5)];
                link = [link stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                link = [link stringByReplacingOccurrencesOfString:@"'" withString:@""];
            }
            
            NSString *title = nil;
            NSRange aTagRange = [aTagRegex rangeOfFirstMatchInString:news options:0 range:NSMakeRange(0, news.length)];
            if (aTagRange.length != 0) {
                title = [news substringWithRange:NSMakeRange(aTagRange.location + aTagRange.length, news.length - aTagRange.location - aTagRange.length)];
                title = [title clearStrings:@[@"<em>",@"</em>",@"</a>",@"</h3>"]];
            }
            NSMutableDictionary *newsDic = [NSMutableDictionary dictionary];
            newsDic[@"link"] = link;
            newsDic[@"title"] = title;
            newsDic[@"authorTime"] = authorTime;

            [models addObject:newsDic];
        }
    }
    return [models copy];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCellIdentifier" forIndexPath:indexPath];
    cell.newsTitle.text = _dataList[indexPath.row][@"title"];
    cell.newsAuthorTime.text = _dataList[indexPath.row][@"authorTime"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MLSWebViewController  *web = [[MLSWebViewController alloc] init];
    web.webURL = [NSURL URLWithString:_dataList[indexPath.row][@"link"]];
    [self.navigationController pushViewController:web animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
