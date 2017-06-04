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
#import "NewsImageCell.h"
#import <MJRefresh.h>
#import <Masonry.h>
#import "UIImageView+WebCache.h"


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
@property (weak, nonatomic) UITableView *tableView;
@property (assign,nonatomic) NSInteger page;
@property (nonatomic,strong) NSMutableArray *dataList;
@property (assign,nonatomic) BOOL showSummary;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *showSummary = [[NSUserDefaults standardUserDefaults] objectForKey:@"kShowSummary"];
    _showSummary = showSummary ? showSummary.boolValue : YES;
    self.dataList = [NSMutableArray array];
    UITableView  *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil] forCellReuseIdentifier:@"NewsCellIdentifier"];
    [tableView registerNib:[UINib nibWithNibName:@"NewsImageCell" bundle:nil] forCellReuseIdentifier:@"NewsImageCellIdentifier"];

    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tableView.superview);
    }];

    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 60;
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshData];
    }];
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self moreData];
    }];

    self.tableView = tableView;

    [self.tableView.mj_header beginRefreshing];
    
    

      // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   NSNumber *showSummary = [[NSUserDefaults standardUserDefaults] objectForKey:@"kShowSummary"];
    if (showSummary && showSummary.boolValue != _showSummary) {
        _showSummary = showSummary.boolValue;
        [self.tableView reloadData];
    }
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
    NSString *url = [NSString stringWithFormat:@"http://news.baidu.com/ns?word=%@&pn=%ld&cl=2&ct=1&tn=news&rn=20&ie=utf-8&bt=0&et=0",[_keyWord urlEncode],(long)_page * 20];
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
     <div class="result" id="1"><h3 class="c-title"><a href="http://news.163.com/17/0602/16/CLUILM79000187VE.html" data-click="{
     'f0':'77A717EA',
     'f1':'9F63F1E4',
     'f2':'4CA6DE6E',
     'f3':'54E5343F',
     't':'1496394283'
     }" target="_blank">《花间提壶方大厨》就是一张刮开后中奖的<em>彩票</em></a></h3>
     
     
     <div class="c-summary c-row c-gap-top-small">
     
     <div class="c-span6"><a class="c_photo" href="http://news.163.com/17/0602/16/CLUILM79000187VE.html" target="_blank"><img class="c-img c-img6" src="http://t11.baidu.com/it/u=2891597401,2504459932&amp;fm=82&amp;s=093853940C3327907519D4DF03007081&amp;w=121&amp;h=81&amp;img.GIF" alt=""></a></div>
     
     
     
     
     <div class="c-span18 c-span-last"><p class="c-author">网易&nbsp;&nbsp;59分钟前</p>(原标题:《花间提壶方大厨》就是一张刮开后中奖的<em>彩票</em>) 随着网剧不断增多,网络视频平台的逐渐形成了一组成对的概念:“头部项目”和“尾部项目”。...  <span class="c-info"><a href="/ns?word=%E5%BD%A9%E7%A5%A8+cont:1284549230&amp;same=2&amp;cl=1&amp;tn=news&amp;rn=30&amp;fm=sd" class="c-more_link" data-click="{'fm':'sd'}">2条相同新闻</a>&nbsp;&nbsp;-&nbsp;&nbsp;<a href="http://cache.baidu.com/c?m=9f65cb4a8c8507ed4fece763104a8023584380143fd3d1027fa3c215cc7958445a64e7b9273f1300ceb402007ad13659e1f23470340925d3ecdf883d87fdcd763bcd7a742613913112c468dcdc3721d65093&amp;p=87769a4787af10f00dbd9b7f095c&amp;newp=c36cd615d9c245f119be9b7c4c4d92695912c10e3cd1c44324b9d71fd325001c1b69e3b823281603d4c6786c15e9241dbdb239256b557ef6&amp;user=baidu&amp;fm=sc&amp;query=%B2%CA%C6%B1&amp;qid=c9a9b3ed000249c3&amp;p1=1" data-click="{'fm':'sc'}" target="_blank" class="c-cache">百度快照</a></span></div></div></div>     */
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"NewsList" ofType:@"txt"];
//    htmlString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    

    
    NSRegularExpression *aNewsDiv = [NSRegularExpression regularExpressionWithPattern:@"<div class=\"result\"[^(百度快照)]*百度快照" options:0 error:nil];
    NSRegularExpression *newsRegex = [NSRegularExpression regularExpressionWithPattern:@"<h3.*?h3>" options:0 error:nil];
    NSRegularExpression *URLRegex=[NSRegularExpression regularExpressionWithPattern:@"href=(\"|')[^(\"|')]*(\"|')" options:0 error:nil];
    NSRegularExpression *aTagRegex=[NSRegularExpression regularExpressionWithPattern:@"<a[^>]*>" options:0 error:nil];

//    <p class="c-author">新浪视频&nbsp;&nbsp;29分钟前</p>
    NSRegularExpression *authorRegex = [NSRegularExpression regularExpressionWithPattern:@"<p class=\"c-author\">[^>]*</p>" options:0 error:nil];
    //    <img class="c-img c-img6" src="http://t11.baidu.com/it/u=2891597401,2504459932&amp;fm=82&amp;s=093853940C3327907519D4DF03007081&amp;w=121&amp;h=81&amp;img.GIF" alt="">
    NSRegularExpression *imgRegex = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]*>" options:0 error:nil];
    NSRegularExpression *summaryRegex = [NSRegularExpression regularExpressionWithPattern:@".*<span" options:0 error:nil];

    NSArray *resultAry = [aNewsDiv matchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length)];
    NSMutableArray *models = [NSMutableArray array];
    
    for (NSTextCheckingResult *result in resultAry) {
        NSString *news = [htmlString substringWithRange:result.range];
        news = [news stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *imgURL = nil;

        NSRange imageRange = [imgRegex rangeOfFirstMatchInString:news options:0 range:NSMakeRange(0, news.length)];
        
        if (imageRange.length != 0) {
           NSString * imgTag = [news substringWithRange:imageRange];
            NSRegularExpression *srcRegex= [NSRegularExpression regularExpressionWithPattern:@"src=(\"|')[^(\"|')]*(\"|')" options:0 error:nil];
           NSRange srcRange = [srcRegex rangeOfFirstMatchInString:imgTag options:0 range:NSMakeRange(0, imgTag.length)];
            if (srcRange.length != 0) {
                imgURL = [[imgTag substringWithRange:NSMakeRange(srcRange.location + 5, srcRange.length - 6)] clearStrings:@[@"amp;"]];
            }
        }
//        http://t10.baidu.com/it/u=2428285320,1649872821&fm=82&s=A9321A9A02884EE806BC75F60300D034&w=121&h=81&img.JPEG
//        http://t10.baidu.com/it/u=2428285320,1649872821&amp;fm=82&amp;s=A9321A9A02884EE806BC75F60300D034&amp;w=121&amp;h=81&amp;img.JPEG
        NSString *authorTime = nil;
        NSString *summary = nil;
       NSRange authorRange = [authorRegex rangeOfFirstMatchInString:news options:0 range:NSMakeRange(0, news.length)];
        if (authorRange.length != 0) {
            
          NSRange summaryRange =  [summaryRegex rangeOfFirstMatchInString:news options:0 range:NSMakeRange(authorRange.location + authorRange.length, news.length - authorRange.location - authorRange.length)];
            
            if (summaryRange.length != 0) {
                summary = [[news substringWithRange:NSMakeRange(summaryRange.location, summaryRange.length - 5)] clearStrings:@[@"</em>",@"<em>"]];
                
            }
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
            newsDic[@"image"] = imgURL;
            newsDic[@"summary"] = summary;
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
    

    if (_dataList[indexPath.row][@"image"]) {
        NewsImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsImageCellIdentifier" forIndexPath:indexPath];
        cell.newsTitle.text = _dataList[indexPath.row][@"title"];
        cell.newsAuthorTime.text = _dataList[indexPath.row][@"authorTime"];
        if (_showSummary && _dataList[indexPath.row][@"summary"]) {
            cell.authorTimeTop.constant = 12;
            cell.summaryLabel.text = _dataList[indexPath.row][@"summary"];

        } else {
            cell.summaryLabel.text = nil;

            cell.authorTimeTop.constant = 0;
        }
        [cell.newsImage sd_setImageWithURL:_dataList[indexPath.row][@"image"] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSLog(@"");
        }];
        return cell;
    }
    
    
    
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCellIdentifier" forIndexPath:indexPath];
    if (_showSummary && _dataList[indexPath.row][@"summary"]) {
        cell.authorTimeTop.constant = 12;
        cell.summaryLabel.text = _dataList[indexPath.row][@"summary"];

    } else {
        cell.authorTimeTop.constant = 0;
        cell.summaryLabel.text = nil;

    }
    cell.newsTitle.text = _dataList[indexPath.row][@"title"];
    cell.newsAuthorTime.text = _dataList[indexPath.row][@"authorTime"];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MLSWebViewController  *web = [[MLSWebViewController alloc] init];
    web.webURL = [NSURL URLWithString:_dataList[indexPath.row][@"link"]];
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return _keyWord;
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor blueColor];
    return self.navigationController.navigationBar.tintColor;
}


@end
